module Dencity
  # Structure methods
  class Structure

    include Request

    attr_accessor :analysis_id
    attr_accessor :user_defined_id
    attr_accessor :structure
    attr_accessor :measure_instances

    # initialize
    def initialize(analysis_id=nil, user_defined_id=nil, path=nil, connection)
      @analysis_id = analysis_id
      @user_defined_id = user_defined_id
      @structure = Hashie::Mash.new
      @measure_instances = Hashie::Mash.new

      @connection = connection

      # initialize with json file
      unless path.nil?
        load_from_file(path)
      end

      @upload_retries = nil

    end

    def push
      begin
        @upload_retries ||= 0

        response = post('api/structure', format_structure)
        @structure.id = response['id'] if response['id']
        return response if response
      rescue StandardError => se
        # Decide if we should fail based on number of retries
        if @upload_retries < 3

          fail 'could not upload'
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

    # load structure from json file into a mash
    def load_from_file(path)
      return unless File.exist?(path)
      json_data = File.read(path)
      load_raw_json(json_data)
    end

    # load structure from raw json
    def load_raw_json(json_data)
      temp = Hashie::Mash.new(MultiJson.load(json_data))
      @structure =  temp.structure ? temp.structure : Hashie::Mash.new
      @measure_instances = temp.measure_instances ? temp.measure_instances : Hashie::Mash.new
      # these could be set in the file
      @analysis_id = temp.analysis_id if temp.analysis_id
      @user_defined_id = temp.user_defined_id if temp.user_defined_id
    end

    # TODO: this method should be removed
    # upload structure to DEnCity
    # expects @structure.structure to not be empty unless a path is passed in
    # will use @analysis.analysis.id if nothing is passed in & @structure.analysis_id is not defined
    def upload(user_defined_id = nil, analysis_id = nil, path = nil)
      if path
        load_from_file(path)
      end

      # add/modify user_defined_id
      @user_defined_id = user_defined_id if user_defined_id

      # set analysis_id in preference order: passed-in analysis_id, analysis_id from @analysis var, nil
      @analysis_id = analysis_id if analysis_id

      # format and post
      response = push
      # set structure.id after upload
      @structure.id = response.id if response.id
      response
    end

    private

    # formats structure parameters for posting
    def format_structure
      # generate name/value pairs for structure metadata
      formatted_meta = []
      @structure.each do |k, v|
        formatted_meta << { name: k, value: v } unless ['id', 'user_defined_id', 'analysis_id'].include?(k)
      end
      new_struct = Hashie::Mash.new
      new_struct.metadata = formatted_meta

      # TODO: what if it's already in the structure hash?
      # add user_defined_id to structure
      new_struct.user_defined_id = @user_defined_id
      new_struct.analysis_id = @analysis_id

      data_hash = Hashie::Mash.new
      data_hash.structure = new_struct
      data_hash.measure_instances = @measure_instances ? @measure_instances : []

      # convert to json
      MultiJson.dump(data_hash)
    end
  end
end
