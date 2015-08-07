require 'dencity/version'
require_relative 'dencity/client'
require_relative 'dencity/response'
require_relative 'dencity/error'

# Main module
module Dencity
  # initialize / connect
  def self.connect(options = {})
    Dencity::Client.new(options)
  end
end
