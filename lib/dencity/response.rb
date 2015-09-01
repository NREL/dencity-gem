# Response Format

module Dencity
  # Response module
  module Response
    def self.create(response_hash, status)
      if response_hash.class.name == 'Array'
        data = Hashie::Mash.new
        data.data = response_hash
      else
        data = response_hash.dup rescue response_hash
      end
      data.extend(self)
      data.status = status
      data
    end
  end
end
