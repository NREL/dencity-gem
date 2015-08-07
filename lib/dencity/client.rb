require 'multi_json'
require 'hashie'
require 'faraday'
require 'faraday_middleware'
require_relative 'request'
require_relative 'client/search'
require_relative 'client/analysis'
require_relative 'client/structure'
require_relative '../faraday/raise_http_exception'

module Dencity
  # API Client class
  class Client
    # connection options
    attr_accessor :options
    attr_accessor :analysis
    attr_accessor :structure

    include Request
    include Dencity::Search
    include Dencity::Analysis
    include Dencity::Structure

    # connect to DEnCity (unauthenticated)
    def initialize(options)
      puts 'Initializing...'
      defaults = {
        username: nil,
        password: nil,
        #access_token: nil,
        host_name: 'https://dencity.org/',
        user_agent: "DEnCity Ruby Client #{Dencity::VERSION}".freeze,
        #cookie: nil,
        logging: nil
      }
      @options = Hashie::Mash.new(defaults.merge(options))
      puts "CONNECTING TO: #{@options.host_name}"
      # connection to site
      @connection = connection

      #initialize analysis and structure to empty hashes
      initialize_analysis
      initialize_structure

    end

    # for authenticated actions
    def login(username, password)

      # TODO: get these values from ENV or config.yml
      @options.username = username
      @options.password = password

      @connection = connection
      post('api/login')

    end

    def logout

      #@cookie = nil
      @options.username = nil
      @options.password = nil
      @connection = nil

    end

    def connected?
      @connection != nil
    end

    private

    def connection(raw = false)
      options = set_options

      Faraday::Connection.new(options) do |c|
        c.use FaradayMiddleware::Mashify unless raw
        # basic auth
        puts c.basic_auth(@options.username, @options.password) unless @options.username.nil? or @options.password.nil?
        c.use FaradayMiddleware::RaiseHttpException
        c.response :json, content_type: /\bjson$/
        c.response :logger if @logging
        c.adapter Faraday.default_adapter
      end
    end

    def set_options

      { headers: {
        'Accept' => 'application/json; charset=utf-8',
        'User-Agent' => @options.user_agent,
        #'Cookie' => @options.cookie,
        #'X-CSRF-Token' => @options.access_token
      }.reject { |_k, v| v.nil? },
        ssl: { verify: false },
        url: @options.host_name
      }
    end


    # initialize analysis variable
    def initialize_analysis
      # analysis hash contains analysis and measure_definitions
      # user_defined_id is set inside the analysis.analysis hash
      # once uploaded, analysis.analysis contains an id, which is used to upload structures
      @analysis = Hashie::Mash.new
      @analysis.analysis = Hashie::Mash.new
      @analysis.measure_definitions = Hashie::Mash.new
    end

    # initialize structure variable
    def initialize_structure
      # structures hash contains: 1)structure from json file (not in name/value pairs),
      # 2) measure_instances, 3) analysis_id, and 4) user_defined_id
      @structure = Hashie::Mash.new
      @structure.analysis_id = nil
      @structure.user_defined_id = nil
      @structure.structure = Hashie::Mash.new
      @structure.measure_instances = Hashie::Mash.new
    end

  end
end
