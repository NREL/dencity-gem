module Dencity
  # Analysis methods
  module Structure

    # load structure from json file
    def load_structure(path)
      # TODO: check that file exists
      File.read(path)
    end
    # upload structure to DEnCity
    # options are in json, analysis_id is not
    def upload_structure(options, analysis_id=nil)
      new_options = format_structure(options, analysis_id)
      post('api/structure', new_options)
    end

    private

    # convert to ruby, structure to name/value pair
    def format_structure(options, analysis_id)
      # convert to ruby hash
      opts_hash = MultiJson.load(options)
      opts_hash['analysis_id'] = analysis_id unless analysis_id.nil?
      # generate name/value pairs
      new_structure = []
      opts_hash['structure'].each do |k, v|
        new_structure << {name: k, value: v}
      end
      # replace old structure with new
      opts_hash.delete('structure')
      opts_hash['structure'] = new_structure
      # convert back to json
      options = MultiJson.dump(opts_hash)
    end

  end
end
