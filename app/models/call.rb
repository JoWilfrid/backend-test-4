# frozen_string_literal: true

class Call < ApplicationRecord
  STATUSES = %i[ringing in_progress completed failed].freeze
  STATUS_FAILED = :failed

  enum status: STATUSES

  validates :sid, :from, :to, presence: true
end
