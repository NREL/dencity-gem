require 'dencity/version'
require_relative 'dencity/client'
require_relative 'dencity/response'
require_relative 'dencity/error'

require 'multi_json'
require 'hashie'
require 'faraday'
require 'faraday_middleware'

# Main module
module Dencity

  # initialize / connect
  def self.connect(options = {})
    Dencity::Client.new(options)
  end
end
