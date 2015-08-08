module Dencity
  # RelatedFile methods
  module RelatedFile
    # upload a file
    # if filename is nil, will use filename in path
    # if structure_id is nil, will use @structure.id
    # TODO: would we ever want to pass-in filedata in memory (no real file?)
    def upload_file(path, file_name = nil, structure_id = nil)
      s_id = (!structure_id && @structure.structure.id) ? @structure.structure.id : structure_id

      file = File.open(path, 'rb')
      the_file = Base64.strict_encode64(file.read)
      file.close

      # file_data param
      file_data = {}
      file_data['file_name'] = file_name.nil? ? File.basename(path) : file_name
      file_data['file'] = the_file

      data = Hashie::Mash.new
      data.structure_id = s_id
      data.file_data = file_data

      post('api/related_file', MultiJson.dump(data))
    end

    # delete an uploaded file
    # if structure_id is nil, will use @structure.id
    def delete_file(file_name, structure_id = nil)
      data = Hashie::Mash.new
      s_id = (!structure_id && @structure.structure.id) ? @structure.structure.id : structure_id
      data.structure_id = s_id
      data.file_name = file_name

      post('api/remove_file', MultiJson.dump(data))
    end
  end
end
