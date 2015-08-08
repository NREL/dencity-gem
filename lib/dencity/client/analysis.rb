module Dencity
  # Analysis methods
  module Analysis
    # return @analysis
    def analysis
      return @analysis
    end

    # analysis_loaded returns true if @analysis.analysis isn't empty
    def analysis_loaded?
      return @analysis.analysis.empty? ? false: true
    end

    # set user_defined_id
    def analysis_set_user_defined_id(user_defined_id)
      @analysis.analysis.user_defined_id = user_defined_id
    end

    # get analysis by id
    def get_analysis(id)
      response = get("api/analyses/#{id}")
      @analysis.analysis = Hashie::Mash.new(response) unless response.error?
      response
    end

    # get analysis by name and user_id
    def retrieve_analysis(name, user_id)
      data = { name: name, user_id: user_id }
      response = get('api/retrieve_analysis', data)
      @analysis.analysis = Hashie::Mash.new(response) unless response.error?
      response
    end

    # load analysis from JSON file
    # use this method to do some processing on analysis params before upload
    def load_analysis(path)
      if File.exists?(path)
        json_data = File.read(path)
        load_analysis_json(json_data)
      end
    end

    # load analysis from raw JSON
    def load_analysis_json(json_data)
      @analysis = Hashie::Mash.new(MultiJson.load(json_data))
    end

    # upload analysis
    # returns analysis_id
    def upload_analysis(path=nil)
      if path.nil?
        raise 'nothing to upload: analysis is empty' if !analysis_loaded?
      else
        load_analysis_json(path)
      end
      response = post('api/analysis', MultiJson.dump(@analysis))
      # set analysis.id after upload
      @analysis.analysis.id = response['analysis']['id'] if response['analysis']['id']
      response
    end

  end
end
