require_relative 'request'

require_relative 'client/search'
require_relative 'client/analysis'
require_relative 'client/structure'
require_relative 'client/related_file'
require_relative '../faraday/raise_http_exception'

module Dencity
  # API Client class
  class Client
    # connection options
    attr_accessor :options
    attr_accessor :analysis
    attr_accessor :structures

    include Request
    include Dencity::Search
    include Dencity::RelatedFile

    # connect to DEnCity (unauthenticated)
    def initialize(options)
      puts 'Initializing...'
      defaults = {
        username: nil,
        password: nil,
        # access_token: nil,
        host_name: 'https://dencity.org/',
        user_agent: "DEnCity Ruby Client #{Dencity::VERSION}".freeze,
        # cookie: nil,
        logging: nil
      }
      @options = Hashie::Mash.new(defaults.merge(options))
      puts "CONNECTING TO: #{@options.host_name}, USER: #{@options.username}"
      # connection to site
      @connection = connect

      @default_number_threads = 4

      # initialize analysis and structures
      initialize_analysis
      # array of structures
      @structures = []
      @analysis = nil

    end

    # for authenticated actions
    def login(username, password)
      # TODO: get these values from ENV or config.yml
      @options.username = username
      @options.password = password

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
    def load_structure(analysis_id=nil, user_defined_id=nil, path=nil)
      @structures << Dencity::Structure.new(analysis_id, user_defined_id, path, @connection)
      @structures.last
    end

    # bulk upload structures
    def bulk_upload(number_of_threads=@default_number_threads)
      Parallel.each(@structures, number_of_threads: number_of_threads) do |structure|
        structure.push
      end
    end

    # load analysis
    # this function is needed to pass @connection at least
    def load_analysis(path=nil)
      @analysis = Dencity::Analysis.new(path, @connection)
    end

    private

    def connect(raw = false)
      options = set_options

      Faraday::Connection.new(options) do |c|
        c.use FaradayMiddleware::Mashify unless raw
        # basic auth
        puts c.basic_auth(@options.username, @options.password) unless @options.username.nil? || @options.password.nil?
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

    # initialize analysis variable
    def initialize_analysis
      # analysis hash contains analysis and measure_definitions
      # user_defined_id is set inside the analysis.analysis hash
      # once uploaded, analysis.analysis contains an id, which is used to upload structures
      @analysis = Hashie::Mash.new
      @analysis.analysis = Hashie::Mash.new
      @analysis.measure_definitions = Hashie::Mash.new
    end

  end
end

=begin

d = Dencity::Client.new
d.structure.from_json(a_json)

d.structure = {Soemthigntsutelkjasdflkjasldfj}
d.structure.anlaysis_id = "something else"
d.structure.push




s = d.add_structure_from_file(a)
s.push
s = d.add_structure_from_file(b)



d.structures[8] = "lasdkjflaskdjf"

d.structures.each do |s|
  s.analysis_id = 'alskdjf'
end


d.bulk_upload_structures

#
d.structures.bulk_upload

=end

