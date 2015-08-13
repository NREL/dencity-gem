# Document me!

module Dencity
  # Response module
  module Response
    def self.create(response_hash, status)
      data = response_hash.data.dup rescue response_hash
      data.extend(self)
      data.status = status
      data
    end
  end
end
