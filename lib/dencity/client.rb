require_relative 'request'
require_relative 'client/search'
require_relative 'client/analysis'
require_relative 'client/structure'
require_relative '../faraday/raise_http_exception'

require 'fileutils'
require 'yaml'

module Dencity
  # API Client class
  class Client
    # connection options
    attr_accessor :options
    attr_accessor :analysis
    attr_accessor :structures

    include Request
    include Dencity::Search

    # connect to DEnCity (unauthenticated)
    def initialize(options = {})
      puts 'Initializing...'
      defaults = {
        username: nil,
        password: nil,
        host_name: 'https://dencity.org',
        user_agent: "DEnCity Ruby Client #{Dencity::VERSION}".freeze,
        logging: nil
      }

      @options = Hashie::Mash.new(defaults.merge(options))
      # connection to site
      @connection = connect

      @default_number_threads = 4

      # initialize analysis and structures
      # array of structures
      @structures = []
      @analysis = nil
    end

    # for authenticated actions
    def login(username = nil, password = nil)
      # check config.yml
      if !username.nil? && !password.nil?
        @options.username = username
        @options.password = password
      else
        # load login info from config file
        config_path = File.expand_path('~') + '/.dencity'
        config_name = 'config.yml'
        if File.exist?(config_path + '/' + config_name)
          puts "loading config settings from #{config_path + '/' + config_name}"

          config = YAML.load_file(config_path + '/' + config_name)
          puts "HEY! #{Hashie::Mash.new(config).inspect}"
          puts "CONFIG: #{config.inspect}"
          @options.username = config[:username]
          @options.password = config[:password]
          @options.host_name = config[:host_name]

        else
          # location of template file
          FileUtils.mkdir_p(config_path)
          puts default_yaml
          File.open(config_path + '/' + config_name, 'w') do |file|
            file << default_yaml.to_yaml
          end
          fail "******** Please fill in user credentials in #{config_path}/#{config_name} file.  DO NOT COMMIT THIS FILE. **********"
        end

      end

      @connection = connect
      post('api/login')
    end

    def logout
      # @cookie = nil
      @options.username = nil
      @options.password = nil
      @connection = nil
    end

    def connected?
      @connection != nil
    end

    # load structure
    def load_structure(analysis_id = nil, user_defined_id = nil, path = nil)
      @structures << Dencity::Structure.new(analysis_id, user_defined_id, path, @connection)
      @structures.last
    end

    # bulk upload structures
    def bulk_upload_structures(number_of_threads = @default_number_threads)
      Parallel.each(@structures, number_of_threads: number_of_threads) do |structure|
        structure.push
      end
    end

    # load analysis
    # this function is needed to pass @connection at least
    def load_analysis(path = nil)
      @analysis = Dencity::Analysis.new(path, @connection)
    end

    # retrieve analysis
    # must pass in @connection
    def retrieve_analysis_by_name(name, user_id)
      @analysis = Dencity::Analysis.new(nil, @connection)
      @analysis.retrieve_by_name(name, user_id)
    end

    # retrieve analysis by ID
    # must pass in @connection
    def retrieve_analysis_by_id(id)
      @analysis = Dencity::Analysis.new(nil, @connection)
      @analysis.retrieve_by_id(id)
    end

    # generic GET action to retrieve from DEnCity
    # example paths:  'analyses', 'structures/<structure_id>'
    def dencity_get(path)
      get(path)
    end

    private

    def connect(raw = false)
      options = set_options
      puts "CONNECTING TO: #{@options.host_name}, USER: #{@options.username}"
      Faraday::Connection.new(options) do |c|
        c.use FaradayMiddleware::Mashify unless raw
        # basic auth
        c.basic_auth(@options.username, @options.password) unless @options.username.nil? || @options.password.nil?
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
        # 'Cookie' => @options.cookie,
        # 'X-CSRF-Token' => @options.access_token
      }.reject { |_k, v| v.nil? },
        ssl: { verify: false },
        url: @options.host_name
      }
    end

    def default_yaml
      settings = { host_name: 'http://localhost:3000', username: 'ENTER_DENCITY_USERNAME', password: 'ENTER_DENCITY_PASSWORD' }
    end
  end
end
