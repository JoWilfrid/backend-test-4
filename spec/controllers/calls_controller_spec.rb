# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe CallsController, type: :controller do
  let(:sid) { 'azertyuiop' }
  let(:from) { '+33600000000' }
  let(:to) { '+33611111111' }
  let(:call) { calls(:from_paris) }
  let(:default_params) do
    {
      'CallSid' => sid,
      'From' => from,
      'To' => to
    }
  end

  describe '#index' do
    it 'should work' do
      get :index

      expect(response).to be_success
    end
  end

  describe '#create' do
    context 'ringing' do
      before { Call.any_instance.expects(:ringing?).returns(true) }

      it 'should return welcome message' do
        expected_response = TwilioCall.answer(:welcome_message).to_s

        post :create, params: default_params

        expect(response.body).to eq expected_response
      end
    end

    context 'not ringing or in progress' do
      before do
        Call.any_instance.expects(:ringing?).returns(false)
        Call.any_instance.expects(:in_progress?).returns(false)
      end

      it 'should return & render no content' do
        post :create, params: default_params

        expect(response.body).to be_blank
      end
    end

    context 'after welcome message' do
      before do
        Call.any_instance.expects(:ringing?).returns(false)
        Call.any_instance.expects(:in_progress?).returns(true)
      end

      context 'no digit given' do
        it 'should render warn_unknown_action' do
          expected_response = TwilioCall.answer(:warn_unknown_action).to_s

          post :create, params: default_params

          expect(response.body).to eq expected_response
        end
      end

      context 'bad digit given' do
        it 'should render warn_unknown_action' do
          expected_response = TwilioCall.answer(:warn_unknown_action).to_s

          post :create, params: default_params.merge('Digits' => 5)

          expect(response.body).to eq expected_response
        end
      end

      context 'digit 1 given' do
        it 'should ask twilio to forward call' do
          expected_response = TwilioCall.answer(:call_my_number).to_s

          post :create, params: default_params.merge('Digits' => 1)

          expect(response.body).to eq expected_response
        end
      end

      context 'digit 2 given' do
        it 'should ask twilio to record message' do
          expected_response = TwilioCall.answer(:record_message).to_s

          post :create, params: default_params.merge('Digits' => 2)

          expect(response.body).to eq expected_response
        end
      end
    end
  end

  describe '#update_status' do
    it 'should update status' do
      expected_status = 'completed'
      params = {
        'CallSid' => call.sid,
        'From' => call.from,
        'To' => call.to,
        'CallStatus' => expected_status
      }

      post :update_status, params: params

      call.reload

      expect(call.status).to eq expected_status
    end
  end

  describe '#register_message' do
    it 'should update call with message url & duration' do
      expected_message_record_url = 'https://test.localhost/recording.mp3'
      expected_message_duration = 42
      params = {
        'CallSid' => call.sid,
        'RecordingUrl' => expected_message_record_url,
        'RecordingDuration' => expected_message_duration
      }

      post :register_message, params: params

      call.reload

      expect(call.message_record_url).to eq expected_message_record_url
      expect(call.message_duration).to eq expected_message_duration
    end
  end

  describe '#failure' do
    it 'should update status to register failure' do
      expected_status = 'failed'
      params = {
        'CallSid' => call.sid,
        'From' => call.from,
        'To' => call.to
      }

      post :failure, params: params

      call.reload

      expect(call.status).to eq expected_status
    end
  end
end
# rubocop:enable Metrics/BlockLength
