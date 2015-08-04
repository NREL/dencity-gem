module Dencity
  # Analysis methods
  module Analysis

    # get analysis by id
    def get_analysis(id)
      get("api/analyses/#{id}")
    end
    # get analysis by name and user_id
    def retrieve_analysis(name, user_id)
      data = {name: name, user_id: user_id}
      puts "DATA: #{data}"
      get("api/retrieve_analysis", data)
    end
  end
end
