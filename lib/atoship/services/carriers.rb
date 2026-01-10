# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Carriers service for carrier account management
    class Carriers < Base
      def list
        get('/api/carriers')
      end

      def get(carrier_id)
        get("/api/carriers/#{carrier_id}")
      end

      def list_accounts
        get('/api/carriers/accounts')
      end

      def add_account(carrier, credentials)
        post('/api/carriers/accounts', body: {
          carrier: carrier,
          credentials: credentials
        })
      end

      def update_account(account_id, credentials)
        patch("/api/carriers/accounts/#{account_id}", body: {
          credentials: credentials
        })
      end

      def delete_account(account_id)
        delete("/api/carriers/accounts/#{account_id}")
      end

      def test_account(account_id)
        post("/api/carriers/accounts/#{account_id}/test")
      end

      def get_balance(carrier)
        get("/api/carriers/#{carrier}/balance")
      end

      def add_funds(carrier, amount)
        post("/api/carriers/#{carrier}/add-funds", body: { amount: amount })
      end

      def get_insurance_options(carrier)
        get("/api/carriers/#{carrier}/insurance")
      end

      def get_special_services(carrier)
        get("/api/carriers/#{carrier}/special-services")
      end

      def get_holidays(carrier, year: nil)
        params = year ? { year: year } : {}
        get("/api/carriers/#{carrier}/holidays", params: params)
      end

      def get_transit_times(carrier, from_zip, to_zip, service_type: nil)
        params = {
          fromZip: from_zip,
          toZip: to_zip
        }
        params[:service] = service_type if service_type
        
        get("/api/carriers/#{carrier}/transit-times", params: params)
      end

      def get_service_maps(carrier)
        get("/api/carriers/#{carrier}/service-maps")
      end

      def get_restrictions(carrier)
        get("/api/carriers/#{carrier}/restrictions")
      end

      def get_surcharges(carrier, service_type: nil)
        params = service_type ? { service: service_type } : {}
        get("/api/carriers/#{carrier}/surcharges", params: params)
      end

      def validate_account_address(carrier, address)
        post("/api/carriers/#{carrier}/validate-address", body: address)
      end

      def get_label_specifications(carrier)
        get("/api/carriers/#{carrier}/label-specs")
      end

      def get_tracking_url(carrier, tracking_number)
        get("/api/carriers/#{carrier}/tracking-url", params: {
          trackingNumber: tracking_number
        })
      end

      def get_customs_forms(carrier, country)
        get("/api/carriers/#{carrier}/customs-forms", params: {
          country: country
        })
      end

      def enable_carrier(carrier_id)
        post("/api/carriers/#{carrier_id}/enable")
      end

      def disable_carrier(carrier_id)
        post("/api/carriers/#{carrier_id}/disable")
      end

      def set_default_carrier(carrier_id)
        post("/api/carriers/#{carrier_id}/set-default")
      end
    end
  end
end