# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TwilioCall do
  subject { TwilioCall }

  describe '#answer' do
    context 'unexisting method' do
      it 'should fallback on warn_unknown_action' do
        fallback_method = :warn_unknown_action

        subject.expects(fallback_method).once

        subject.answer(:unexisting_method)
      end
    end

    context 'existing method' do
      it 'should call it' do
        method = :ask_for_a_digit

        subject.expects(:send).with(method).once

        subject.answer(method)
      end
    end
  end

  describe 'methods returning TwiML response' do
    %i[ask_for_a_digit welcome_message call_my_number record_message warn_unknown_action].each do |method|
      it "#{method} should return a Twilio::TwiML::VoiceResponse" do
        expect(subject.send(method)).to be_an_instance_of Twilio::TwiML::VoiceResponse
      end
    end
  end
end
