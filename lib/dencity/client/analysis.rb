module Dencity
  # Analysis methods
  class Analysis
    include Request

    attr_accessor :analysis
    attr_accessor :measure_definitions

    # initialize
    def initialize(path = nil, connection)
      # for analysis, user_defined_id is created in @analysis (not a separate variable)
      @analysis = Hashie::Mash.new
      @measure_definitions = Hashie::Mash.new

      @connection = connection

      # initialize with JSON
      unless path.nil?
        load_from_file(path)
      end

      @upload_retries = nil
    end

    # get analysis by id
    def retrieve_by_id(id)
      response = get("api/analyses/#{id}")
      @analysis = Hashie::Mash.new(response) unless response.error?
      response
    end

    # get analysis by name and user_id
    def retrieve_by_name(name, user_id)
      data = { name: name, user_id: user_id }
      response = get('api/retrieve_analysis', data)
      @analysis = Hashie::Mash.new(response) unless response.error?
      response
    end

    # load analysis from JSON file
    def load_from_file(path)
      return unless File.exist?(path)
      json_data = File.read(path)
      load_raw_json(json_data)
    end

    # load analysis from raw JSON
    def load_raw_json(json_data)
      temp = Hashie::Mash.new(MultiJson.load(json_data))
      @analysis = temp.analysis ? temp.analysis : Hashie::Mash.new
      @measure_definitions = temp.measure_definitions ? temp.measure_definitions : Hashie::Mash.new
    end

    def push
      begin
        @upload_retries ||= 0

        response = post('api/analysis', format_analysis)
        @analysis.id = response.analysis.id if response.analysis.id
        return response if response
      rescue StandardError => se
        # Decide if we should fail based on number of retries
        if @upload_retries < 3

          raise 'could not upload'
        else
          # or here: @upload_retries = nil
          return se
        end
      end
    rescue => e
      @upload_retries += 1
      sleep 2
      retry
    ensure
      # always do this
      # verify that this is only called if the retry is not triggered
      @upload_retries = nil
    end

    private

    # format analysis for uploading
    def format_analysis
      data_hash = Hashie::Mash.new
      data_hash.analysis = @analysis
      data_hash.measure_definitions = @measure_definitions
      MultiJson.dump(data_hash)
    end
  end
end
