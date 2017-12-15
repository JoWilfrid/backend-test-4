# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Call, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:sid) }
    it { should validate_presence_of(:from) }
    it { should validate_presence_of(:to) }
  end
end
