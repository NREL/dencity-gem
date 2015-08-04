module Dencity
  # Search methods
  module Search
    # filters: array of hashes with keys: name, value, operator
    # return_only: array of metadata to return
    # If blank, all metadata will be returned
    # for iterating over results set (100 per page)
    def search(\
      filters = [{ name: 'building_type', value: 'Office', operator: '=' }],\
      return_only = [], page = 0)
      # must have 1 filter or search won't work
      object = {}
      object['filters'] = filters
      object['return_only'] = return_only unless return_only.nil?
      object['page'] = page

      data = JSON.generate(object)
      puts "DATA: #{data}"
      post('api/search', data)
    end
  end
end
