# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Shipping service for rate quotes and label generation
    class Shipping < Base
      def get_rates(rate_request)
        response = post('/api/shipping/rates', body: rate_request)
        response.map { |rate| Rate.new(rate) }
      end

      def compare_rates(rate_request)
        response = post('/api/shipping/rates/compare', body: rate_request)
        ComparisonResult.new(response)
      end

      def purchase_label(rate_id: nil, order_id: nil, shipment_data: nil)
        body = {}
        body[:rateId] = rate_id if rate_id
        body[:orderId] = order_id if order_id
        body[:shipment] = shipment_data if shipment_data
        
        response = post('/api/shipping/labels', body: body)
        Label.new(response)
      end

      def get_label(label_id)
        response = get("/api/shipping/labels/#{label_id}")
        Label.new(response)
      end

      def cancel_label(label_id, reason: nil)
        post("/api/shipping/labels/#{label_id}/cancel", body: { reason: reason })
      end

      def reprint_label(label_id, format: 'pdf')
        get("/api/shipping/labels/#{label_id}/reprint", params: { format: format })
      end

      def batch_purchase_labels(shipments)
        response = post('/api/shipping/labels/batch', body: { shipments: shipments })
        response.map { |label| Label.new(label) }
      end

      def create_manifest(label_ids)
        post('/api/shipping/manifests', body: { labelIds: label_ids })
      end

      def get_manifest(manifest_id)
        get("/api/shipping/manifests/#{manifest_id}")
      end

      def create_scan_form(carrier, label_ids)
        post('/api/shipping/scan-forms', body: {
          carrier: carrier,
          labelIds: label_ids
        })
      end

      def schedule_pickup(pickup_data)
        post('/api/shipping/pickups', body: pickup_data)
      end

      def cancel_pickup(pickup_id)
        delete("/api/shipping/pickups/#{pickup_id}")
      end

      def get_service_types(carrier)
        get('/api/shipping/services', params: { carrier: carrier })
      end

      def get_package_types(carrier)
        get('/api/shipping/packages', params: { carrier: carrier })
      end

      def estimate_delivery_date(from_zip, to_zip, service_type, ship_date: nil)
        params = {
          fromZip: from_zip,
          toZip: to_zip,
          service: service_type
        }
        params[:shipDate] = ship_date if ship_date
        
        get('/api/shipping/delivery-estimate', params: params)
      end

      def get_zones(from_zip, to_zips)
        post('/api/shipping/zones', body: {
          fromZip: from_zip,
          toZips: to_zips
        })
      end

      def validate_customs(customs_data)
        post('/api/shipping/customs/validate', body: customs_data)
      end

      def create_return_label(original_label_id, return_address: nil)
        body = { originalLabelId: original_label_id }
        body[:returnAddress] = return_address if return_address
        
        response = post('/api/shipping/returns', body: body)
        Label.new(response)
      end
    end

    # Rate wrapper class
    class Rate
      attr_reader :id, :carrier, :service, :rate, :delivery_days, :estimated_delivery,
                  :currency, :retail_rate, :insurance_included, :tracking_included

      def initialize(data)
        @id = data['id']
        @carrier = data['carrier']
        @service = data['service']
        @rate = data['rate']
        @delivery_days = data['deliveryDays']
        @estimated_delivery = data['estimatedDelivery']
        @currency = data['currency'] || 'USD'
        @retail_rate = data['retailRate']
        @insurance_included = data['insuranceIncluded'] || false
        @tracking_included = data['trackingIncluded'] || true
      end

      def discounted?
        retail_rate && rate < retail_rate
      end

      def discount_percentage
        return 0 unless discounted?
        ((retail_rate - rate) / retail_rate * 100).round(2)
      end
    end

    # Label wrapper class
    class Label
      attr_reader :id, :tracking_number, :label_url, :carrier, :service,
                  :rate, :created_at, :status, :from_address, :to_address,
                  :parcel, :reference_number, :insurance_amount

      def initialize(data)
        @id = data['id']
        @tracking_number = data['trackingNumber']
        @label_url = data['labelUrl']
        @carrier = data['carrier']
        @service = data['service']
        @rate = data['rate']
        @created_at = data['createdAt']
        @status = data['status']
        @from_address = data['fromAddress']
        @to_address = data['toAddress']
        @parcel = data['parcel']
        @reference_number = data['referenceNumber']
        @insurance_amount = data['insuranceAmount']
      end

      def active?
        status == 'active'
      end

      def cancelled?
        status == 'cancelled'
      end

      def refunded?
        status == 'refunded'
      end
    end

    # Rate comparison result
    class ComparisonResult
      attr_reader :cheapest, :fastest, :best_value, :all_rates

      def initialize(data)
        @cheapest = data['cheapest'] ? Rate.new(data['cheapest']) : nil
        @fastest = data['fastest'] ? Rate.new(data['fastest']) : nil
        @best_value = data['bestValue'] ? Rate.new(data['bestValue']) : nil
        @all_rates = (data['allRates'] || []).map { |rate| Rate.new(rate) }
      end

      def has_rates?
        !all_rates.empty?
      end
    end
  end
end