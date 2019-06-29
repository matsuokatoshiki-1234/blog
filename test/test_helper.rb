ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Warden::Test::Helpers
  include ActionDispatch::TestProcess
  include Comparable
  require 'fileutils'

  def is_descending_order(array)
    time = ''
    array.each_with_index do |item, i|
      if i === 0
        time = item.created_at
      elsif i === array.length - 1
        return false if time < item.created_at

        return true
      else
        return false if time < item.created_at

        time = item.created_at
      end
    end
  end

  def create_text(number)
    text = ''
    number.times { text += 'a' }
    text
  end

end
