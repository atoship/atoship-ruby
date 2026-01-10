# frozen_string_literal: true

module Atoship
  # Base error class for all atoship SDK errors
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message = nil, code: nil, details: nil)
      super(message)
      @code = code
      @details = details
    end
  end

  # Configuration errors
  class ConfigurationError < Error; end

  # API errors
  class APIError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code: nil, response_body: nil, code: nil)
      super(message, code: code)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Authentication errors
  class AuthenticationError < APIError; end

  # Validation errors
  class ValidationError < APIError
    attr_reader :validation_errors

    def initialize(message, validation_errors: nil, **kwargs)
      super(message, **kwargs)
      @validation_errors = validation_errors
    end
  end

  # Rate limit errors
  class RateLimitError < APIError
    attr_reader :retry_after

    def initialize(message, retry_after: nil, **kwargs)
      super(message, **kwargs)
      @retry_after = retry_after
    end
  end

  # Network errors
  class NetworkError < Error; end

  # Timeout errors
  class TimeoutError < NetworkError; end

  # Not found errors
  class NotFoundError < APIError; end

  # Server errors
  class ServerError < APIError; end
end