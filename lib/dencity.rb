require 'dencity/version'
require 'ostruct'
require_relative 'dencity/client'
require_relative 'dencity/response'

# Main module
module Dencity
  # initialize / connect
  def self.connect(options = {})
    Dencity::Client.new(options)
  end
end
