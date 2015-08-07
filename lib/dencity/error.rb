module Dencity
  class Error < StandardError; end

  # For 400's
  class BadRequest < Error; end

  # For 401's
  class Unauthorized < Error; end

  # For 404's.
  class NotFound < Error; end

  # For 406's.
  class NotAcceptable < Error; end

  # For 500's
  class InternalServerError < Error; end

end
