# frozen_string_literal: true

require 'twilio-ruby'

class CallsController < ApplicationController
  skip_before_action :verify_authenticity_token, except: :index
  before_action :set_locale, except: :index
  before_action :set_call, except: %i[index register_message].freeze
  before_action :update_call_status_and_duration!, except: %i[index failure register_message].freeze

  DIGIT_CALLBACKS = {
    '1' => :call_my_number,
    '2' => :record_message,
    'unknown' => :warn_unknown_action
  }.freeze

  #
  # GET /
  #
  def index
    @calls = Call.all
  end

  #
  # POST /
  # Handles call
  #
  def create
    # Say hello & ask for a digit if ringing
    render xml: TwilioCall.answer(:welcome_message) and return if @call.ringing?

    # Do nothing if registering message
    head :no_content and return unless @call.in_progress?

    response_type = DIGIT_CALLBACKS[params['Digits']] || DIGIT_CALLBACKS['unknown']

    # Forward (call or register)
    render xml: TwilioCall.answer(response_type)
  end

  #
  # POST /update_status
  # Updates the call's status
  #
  # If there's no code in the following method, that means that everything is placed into around filters.
  # We want to keep this method, even empty, even if it looks like #failure, for semantic reasons.
  #
  def update_status
    head :no_content
  end

  #
  # POST /register_message
  # Registers voice message
  #
  def register_message
    @call = Call.find_by(sid: params.require('CallSid'))

    @call.message_record_url = params.require('RecordingUrl')
    @call.message_duration = params.require('RecordingDuration')

    @call.save!
  end

  #
  # POST /failure
  # Registers the call's failure
  #
  def failure
    update_call_status_and_duration!(Call::STATUS_FAILED)
  end

  private

  def set_locale
    I18n.locale = params.fetch('CallerCountry', 'fr').downcase.to_sym
  end

  def extract_call_params
    [
      params.require('CallSid'),
      params.require('From'),
      params.require('To')
    ]
  end

  def set_call
    sid, from, to = extract_call_params

    @call = Call.where(sid: sid, from: from, to: to).first_or_create!
  end

  def update_call_status_and_duration!(status = nil)
    @call.status = (status || params['CallStatus']).to_s.underscore unless @call.failed?
    @call.duration = params['CallDuration']

    @call.save!
  end
end
