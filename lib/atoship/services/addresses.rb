# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Addresses service for address management and validation
    class Addresses < Base
      def validate(address_data)
        response = post('/api/addresses/validate', body: address_data)
        ValidationResult.new(response)
      end

      def search(query, limit: 10)
        get('/api/addresses/search', params: { q: query, limit: limit })
      end

      def autocomplete(query, country: 'US')
        get('/api/addresses/autocomplete', params: { q: query, country: country })
      end

      def standardize(address_data)
        post('/api/addresses/standardize', body: address_data)
      end

      def verify_deliverability(address_data)
        post('/api/addresses/verify-deliverability', body: address_data)
      end

      def get_timezone(address_data)
        post('/api/addresses/timezone', body: address_data)
      end

      def calculate_distance(from_address, to_address, unit: 'miles')
        post('/api/addresses/distance', body: {
          from: from_address,
          to: to_address,
          unit: unit
        })
      end

      def geocode(address_data)
        post('/api/addresses/geocode', body: address_data)
      end

      def reverse_geocode(latitude, longitude)
        get('/api/addresses/reverse-geocode', params: {
          lat: latitude,
          lng: longitude
        })
      end

      def validate_batch(addresses)
        post('/api/addresses/validate-batch', body: { addresses: addresses })
      end

      def get_saved_addresses(user_id: nil)
        params = user_id ? { userId: user_id } : {}
        get('/api/addresses/saved', params: params)
      end

      def save_address(address_data, label: nil)
        body = address_data.merge(label ? { label: label } : {})
        post('/api/addresses/save', body: body)
      end

      def update_saved_address(address_id, address_data)
        patch("/api/addresses/saved/#{address_id}", body: address_data)
      end

      def delete_saved_address(address_id)
        delete("/api/addresses/saved/#{address_id}")
      end

      def set_default_address(address_id, type: 'shipping')
        post("/api/addresses/saved/#{address_id}/set-default", body: { type: type })
      end
    end

    # Address validation result wrapper
    class ValidationResult
      attr_reader :valid, :errors, :suggestions, :normalized_address, :metadata

      def initialize(data)
        @valid = data['valid'] || false
        @errors = data['errors'] || []
        @suggestions = data['suggestions'] || []
        @normalized_address = data['normalizedAddress']
        @metadata = data['metadata'] || {}
      end

      def valid?
        @valid
      end

      def has_suggestions?
        !@suggestions.empty?
      end

      def has_errors?
        !@errors.empty?
      end
    end
  end
end