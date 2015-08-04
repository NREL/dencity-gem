require 'json'
require 'faraday'
require 'faraday_middleware'
require_relative 'request'
require_relative 'client/search'
require_relative 'client/analysis'

module Dencity
  # API Client class
  class Client
    # connection options
    attr_accessor :options

    include Request
    include Dencity::Search
    include Dencity::Analysis

    # connect to DEnCity (unauthenticated)
    def initialize(options)
      puts 'Initializing...'
      defaults = {
        username: nil,
        password: nil,
        access_token: nil,
        host_name: 'https://dencity.org/',
        endpoint_base_url: 'api/',
        user_agent: "DEnCity Ruby Client #{Dencity::VERSION}".freeze,
        cookie: nil,
        logging: nil
      }

      @options = OpenStruct.new(defaults.merge(options))
      puts "CONNECTING TO: #{@options.host_name}"
      # connection to site
      @connection = connection

      # get all API methods
      # methods = get('api')
      # puts "METHODS: #{methods}"
    end

    # for authenticated actions
    def login(_options = {})
    end

    def logout
      response = post('user/logout')
      @cookie = nil
      @connection = nil
      response
    end

    def connected?
      @connection != nil
    end

    private

    def connection(raw = false)
      options = set_options

      Faraday::Connection.new(options) do |c|
        c.use FaradayMiddleware::Mashify unless raw
        c.response :json, content_type: /\bjson$/
        c.response :logger if @logging
        c.adapter Faraday.default_adapter
      end
    end

    def set_options
      { headers: {
        'Accept' => 'application/json; charset=utf-8',
        'User-Agent' => @options.user_agent,
        'Cookie' => @options.cookie,
        'X-CSRF-Token' => @options.access_token
      }.reject { |_k, v| v.nil? },
        ssl: { verify: false },
        url: @options.host_name
      }
    end
  end
end
