# frozen_string_literal: true

module CallsHelper
  def hide_number(number)
    return number unless Rails.env.production?

    first_four = number.first(4)
    last_four = number.last(4)
    complement = 'X' * (number.length - 8) # 4 + 4 = 8

    "#{first_four}#{complement}#{last_four}"
  end
end
