# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'multi_json'
require 'atoship/services/orders'
require 'atoship/services/addresses'
require 'atoship/services/shipping'
require 'atoship/services/tracking'
require 'atoship/services/users'
require 'atoship/services/carriers'
require 'atoship/services/webhooks'
require 'atoship/services/admin'

module Atoship
  # Main client class for interacting with atoship API
  class Client
    attr_reader :api_key, :base_url, :timeout, :max_retries, :debug
    attr_reader :orders, :addresses, :shipping, :tracking, :users, :carriers, :webhooks, :admin

    def initialize(api_key: nil, base_url: nil, timeout: nil, max_retries: nil, debug: nil)
      config = Atoship.configuration
      
      @api_key = api_key || config.api_key
      @base_url = base_url || config.base_url
      @timeout = timeout || config.timeout
      @max_retries = max_retries || config.max_retries
      @debug = debug || config.debug

      validate_configuration!
      
      # Initialize service modules
      @orders = Services::Orders.new(self)
      @addresses = Services::Addresses.new(self)
      @shipping = Services::Shipping.new(self)
      @tracking = Services::Tracking.new(self)
      @users = Services::Users.new(self)
      @carriers = Services::Carriers.new(self)
      @webhooks = Services::Webhooks.new(self)
      @admin = Services::Admin.new(self)
    end

    def connection
      @connection ||= Faraday.new(url: base_url) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        
        conn.request :retry, {
          max: max_retries,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed],
          retry_statuses: [429, 502, 503, 504],
          retry_block: lambda do |env, _opts, retries, exception|
            if debug
              puts "[RETRY #{retries}] #{exception.class}: #{exception.message}"
            end
          end
        }

        conn.headers['Authorization'] = "Bearer #{api_key}"
        conn.headers['User-Agent'] = "atoship-ruby-sdk/#{Atoship::VERSION}"
        conn.headers['Content-Type'] = 'application/json'
        
        conn.options.timeout = timeout
        conn.options.open_timeout = 10
        
        conn.response :logger if debug
        
        conn.adapter Faraday.default_adapter
      end
    end

    def request(method, path, params: nil, body: nil, headers: {})
      response = connection.send(method) do |req|
        req.url path
        req.params = params if params
        req.body = MultiJson.dump(body) if body && !body.empty?
        req.headers.merge!(headers) unless headers.empty?
      end

      handle_response(response)
    rescue Faraday::TimeoutError => e
      raise TimeoutError.new("Request timed out: #{e.message}")
    rescue Faraday::ConnectionFailed => e
      raise NetworkError.new("Connection failed: #{e.message}")
    rescue Faraday::Error => e
      raise NetworkError.new("Network error: #{e.message}")
    end

    def get(path, **options)
      request(:get, path, **options)
    end

    def post(path, **options)
      request(:post, path, **options)
    end

    def put(path, **options)
      request(:put, path, **options)
    end

    def patch(path, **options)
      request(:patch, path, **options)
    end

    def delete(path, **options)
      request(:delete, path, **options)
    end

    private

    def validate_configuration!
      raise ConfigurationError, 'API key is required' if api_key.nil? || api_key.empty?
      raise ConfigurationError, 'Base URL is required' if base_url.nil? || base_url.empty?
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 401
        raise AuthenticationError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body
        )
      when 400
        raise ValidationError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body,
          validation_errors: response.body['errors']
        )
      when 404
        raise NotFoundError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body
        )
      when 429
        retry_after = response.headers['Retry-After']&.to_i
        raise RateLimitError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body,
          retry_after: retry_after
        )
      when 500..599
        raise ServerError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body
        )
      else
        raise APIError.new(
          error_message(response),
          status_code: response.status,
          response_body: response.body
        )
      end
    end

    def error_message(response)
      if response.body.is_a?(Hash)
        response.body['message'] || response.body['error'] || "API error: #{response.status}"
      else
        "API error: #{response.status}"
      end
    end
  end
end