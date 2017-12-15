# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CallsHelper, type: :helper do
  describe '#hide_number' do
    context 'non-production environment' do
      it 'should return input' do
        input = :whatever

        expect(hide_number(input)).to eq input
      end
    end

    context 'production environment' do
      it 'should not return the number as is' do
        input = '+33622222222'
        expected = '+336XXXX2222'

        Rails.expects(:env).at_least_once.returns ActiveSupport::StringInquirer.new('production')

        expect(hide_number(input)).to eq expected
      end
    end
  end
end
