# frozen_string_literal: true

class TwilioCall
  class << self
    include Rails.application.routes.url_helpers

    def answer(type = :warn_unknown_action)
      action = respond_to?(type) ? type : :warn_unknown_action

      send(action)
    end

    def ask_for_a_digit(type = :welcome)
      respond(type) do |response|
        response.gather(timeout: 2.minutes, num_digits: 1) do |resp|
          resp.say I18n.t('twilio_call.response.ask_for_a_digit'), language: locale
        end
      end
    end

    alias welcome_message ask_for_a_digit

    def call_my_number
      my_number = ENV.fetch('MY_NUMBER')
      callback_url = update_status_calls_url

      respond(:trying_to_call) do |response|
        response.dial { |call| call.number my_number, status_callback: callback_url }
      end
    end

    def record_message
      callback_url = register_message_calls_url

      respond(:registering) { |response| response.record recording_status_callback: callback_url }
    end

    def warn_unknown_action
      ask_for_a_digit(:unknown_action)
    end

    private

    def locale
      I18n.locale || :fr
    end

    def respond(message_key)
      Twilio::TwiML::VoiceResponse.new do |response|
        message = I18n.t("twilio_call.response.#{message_key}")

        response.say message, language: locale

        yield(response) if block_given?
      end
    end
  end
end
