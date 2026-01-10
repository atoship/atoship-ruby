# frozen_string_literal: true

module Atoship
  # Configuration class for atoship SDK
  class Configuration
    attr_accessor :api_key, :base_url, :timeout, :max_retries, :debug, :logger

    def initialize
      @api_key = ENV['ATOSHIP_API_KEY']
      @base_url = 'https://api.atoship.com'
      @timeout = 30
      @max_retries = 3
      @debug = false
      @logger = nil
    end

    def validate!
      raise ConfigurationError, 'API key is required' if api_key.nil? || api_key.empty?
      raise ConfigurationError, 'Base URL is required' if base_url.nil? || base_url.empty?
      raise ConfigurationError, 'Timeout must be positive' if timeout <= 0
      raise ConfigurationError, 'Max retries must be non-negative' if max_retries < 0
    end
  end
end