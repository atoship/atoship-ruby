# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Tracking service for package tracking
    class Tracking < Base
      def track(tracking_number, carrier: nil)
        params = { trackingNumber: tracking_number }
        params[:carrier] = carrier if carrier
        
        response = get('/api/tracking', params: params)
        TrackingInfo.new(response)
      end

      def track_batch(tracking_numbers)
        response = post('/api/tracking/batch', body: { trackingNumbers: tracking_numbers })
        response.map { |info| TrackingInfo.new(info) }
      end

      def subscribe(tracking_number, webhook_url: nil, email: nil, sms: nil)
        body = { trackingNumber: tracking_number }
        body[:webhookUrl] = webhook_url if webhook_url
        body[:email] = email if email
        body[:sms] = sms if sms
        
        post('/api/tracking/subscribe', body: body)
      end

      def unsubscribe(tracking_number, subscription_id: nil)
        params = { trackingNumber: tracking_number }
        params[:subscriptionId] = subscription_id if subscription_id
        
        delete('/api/tracking/subscribe', params: params)
      end

      def get_subscriptions(tracking_number: nil)
        params = tracking_number ? { trackingNumber: tracking_number } : {}
        get('/api/tracking/subscriptions', params: params)
      end

      def predict_delivery(tracking_number)
        get("/api/tracking/#{tracking_number}/predict")
      end

      def get_proof_of_delivery(tracking_number)
        get("/api/tracking/#{tracking_number}/proof-of-delivery")
      end

      def report_issue(tracking_number, issue_type, description)
        post("/api/tracking/#{tracking_number}/issues", body: {
          type: issue_type,
          description: description
        })
      end

      def get_carrier_by_tracking(tracking_number)
        get('/api/tracking/detect-carrier', params: { trackingNumber: tracking_number })
      end

      def get_tracking_history(tracking_number)
        get("/api/tracking/#{tracking_number}/history")
      end
    end

    # Tracking information wrapper
    class TrackingInfo
      attr_reader :tracking_number, :carrier, :status, :current_location,
                  :delivered, :actual_delivery, :estimated_delivery,
                  :events, :origin, :destination, :weight, :dimensions,
                  :reference_number, :service_type, :signature

      def initialize(data)
        @tracking_number = data['trackingNumber']
        @carrier = data['carrier']
        @status = data['status']
        @current_location = data['currentLocation']
        @delivered = data['delivered'] || false
        @actual_delivery = data['actualDelivery']
        @estimated_delivery = data['estimatedDelivery']
        @events = (data['events'] || []).map { |event| TrackingEvent.new(event) }
        @origin = data['origin']
        @destination = data['destination']
        @weight = data['weight']
        @dimensions = data['dimensions']
        @reference_number = data['referenceNumber']
        @service_type = data['serviceType']
        @signature = data['signature']
      end

      def delivered?
        @delivered
      end

      def in_transit?
        status == 'in_transit'
      end

      def out_for_delivery?
        status == 'out_for_delivery'
      end

      def exception?
        status == 'exception'
      end

      def latest_event
        events.first
      end

      def days_in_transit
        return nil unless events.any?
        
        first_event = events.last
        last_event = delivered? ? events.find { |e| e.delivered? } : events.first
        
        return nil unless first_event && last_event
        
        ((Time.parse(last_event.timestamp) - Time.parse(first_event.timestamp)) / 86400).round
      end
    end

    # Tracking event wrapper
    class TrackingEvent
      attr_reader :timestamp, :description, :location, :status, :details

      def initialize(data)
        @timestamp = data['timestamp']
        @description = data['description']
        @location = data['location']
        @status = data['status']
        @details = data['details']
      end

      def delivered?
        status == 'delivered'
      end

      def exception?
        status == 'exception'
      end

      def out_for_delivery?
        status == 'out_for_delivery'
      end
    end
  end
end