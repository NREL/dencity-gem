module Dencity
  # Analysis methods
  module Structure
    # return @structure
    def structure
      return @structure
    end

    # structure_loaded? returns true if @structure.structure isn't empty
    def structure_loaded?
      return @structure.structure.empty? ? false: true
    end

    # load structure from json file into a mash
    def load_structure(path)
      if File.exists?(path)
        json_data = File.read(path)
        load_structure_json(json_data)
      end
    end

    # load structure from raw json
    def load_structure_json(json_data)
      @structure = Hashie::Mash.new(MultiJson.load(json_data))
    end

    # set structure user_defined_id
    def structure_set_user_defined_id(user_defined_id)
      @structure.user_defined_id = user_defined_id
    end

    # set structure analysis_id
    def structure_set_analysis_id(analysis_id)
      @structure.analysis_id = analysis_id
    end

    # upload structure to DEnCity
    # expects @structure.structure to not be empty unless a path is passed in
    # will use @analysis.analysis.id if nothing is passed in & @structure.analysis_id is not defined
    def upload_structure(user_defined_id=nil, analysis_id=nil, path=nil)

      if path
        load_structure(path)
      end
      raise 'You must load a valid structure before uploading' if !structure_loaded?

      # add/modify user_defined_id
      structure_set_user_defined_id(user_defined_id) if user_defined_id

      # set analysis_id in preference order: passed-in analysis_id, analysis_id from @analysis var, nil
      a_id =  (!analysis_id && @analysis.analysis.id) ? @analysis.analysis.id : analysis_id
      structure_set_analysis_id(a_id)

      # format and post
      post('api/structure', format_structure)
    end

    private

    # formats structure parameters for posting
    def format_structure

      # generate name/value pairs for structure metadata
      formatted_meta = []
      @structure.structure.each do |k, v|
        formatted_meta << {name: k, value: v}
      end
      new_struct = Hashie::Mash.new
      new_struct.metadata = formatted_meta

      # TODO: what if it's already in the structure hash?
      # add user_defined_id to structure
      new_struct.user_defined_id = @structure.user_defined_id
      new_struct.analysis_id = @structure.analysis_id

      data_hash = Hashie::Mash.new
      data_hash.structure = new_struct
      data_hash.measure_instances = @structure.measure_instances ? @structure.measure_instances : []

      # convert back to json
      MultiJson.dump(data_hash)
    end

  end
end
