# frozen_string_literal: true

require 'atoship/services/base'
require 'openssl'
require 'base64'

module Atoship
  module Services
    # Webhooks service for webhook management
    class Webhooks < Base
      def create(url, events, active: true, secret: nil)
        body = {
          url: url,
          events: events,
          active: active
        }
        body[:secret] = secret if secret
        
        post('/api/webhooks', body: body)
      end

      def list(page: 1, limit: 20)
        response = get('/api/webhooks', params: { page: page, limit: limit })
        paginated_response(response)
      end

      def get(webhook_id)
        get("/api/webhooks/#{webhook_id}")
      end

      def update(webhook_id, url: nil, events: nil, active: nil, secret: nil)
        body = {}
        body[:url] = url unless url.nil?
        body[:events] = events unless events.nil?
        body[:active] = active unless active.nil?
        body[:secret] = secret unless secret.nil?
        
        patch("/api/webhooks/#{webhook_id}", body: body)
      end

      def delete(webhook_id)
        delete("/api/webhooks/#{webhook_id}")
      end

      def test(webhook_id, event_type: 'test')
        post("/api/webhooks/#{webhook_id}/test", body: { eventType: event_type })
      end

      def get_deliveries(webhook_id, page: 1, limit: 20)
        response = get("/api/webhooks/#{webhook_id}/deliveries", 
                      params: { page: page, limit: limit })
        paginated_response(response)
      end

      def retry_delivery(webhook_id, delivery_id)
        post("/api/webhooks/#{webhook_id}/deliveries/#{delivery_id}/retry")
      end

      def get_events
        get('/api/webhooks/events')
      end

      def get_event_schema(event_type)
        get("/api/webhooks/events/#{event_type}/schema")
      end

      def rotate_secret(webhook_id)
        post("/api/webhooks/#{webhook_id}/rotate-secret")
      end

      def enable(webhook_id)
        post("/api/webhooks/#{webhook_id}/enable")
      end

      def disable(webhook_id)
        post("/api/webhooks/#{webhook_id}/disable")
      end

      def get_statistics(webhook_id, start_date: nil, end_date: nil)
        params = {}
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        get("/api/webhooks/#{webhook_id}/statistics", params: params)
      end

      # Verify webhook signature
      def self.verify_signature(payload, signature, secret)
        expected_signature = generate_signature(payload, secret)
        secure_compare(signature, expected_signature)
      end

      # Generate webhook signature
      def self.generate_signature(payload, secret)
        hmac = OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
        "sha256=#{hmac}"
      end

      private

      # Constant time string comparison to prevent timing attacks
      def self.secure_compare(a, b)
        return false unless a.bytesize == b.bytesize
        
        l = a.unpack('C*')
        r = b.unpack('C*')
        result = 0
        
        l.zip(r) { |x, y| result |= x ^ y }
        result == 0
      end
    end

    # Webhook helper module for Rails integration
    module Webhook
      class << self
        def verify_signature(payload, signature, secret)
          Services::Webhooks.verify_signature(payload, signature, secret)
        end

        def generate_signature(payload, secret)
          Services::Webhooks.generate_signature(payload, secret)
        end

        # Parse webhook event from request body
        def parse_event(payload, signature = nil, secret = nil)
          if signature && secret
            unless verify_signature(payload, signature, secret)
              raise AuthenticationError, 'Invalid webhook signature'
            end
          end

          MultiJson.load(payload)
        rescue MultiJson::ParseError => e
          raise ValidationError, "Invalid JSON payload: #{e.message}"
        end

        # Rails controller helper
        def handle_event(request, secret)
          signature = request.headers['X-Atoship-Signature']
          payload = request.body.read
          
          event = parse_event(payload, signature, secret)
          
          # Return event for processing
          event
        end
      end
    end
  end
end