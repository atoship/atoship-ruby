# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Users service for user management
    class Users < Base
      def get_profile
        get('/api/users/profile')
      end

      def update_profile(profile_data)
        patch('/api/users/profile', body: profile_data)
      end

      def change_password(current_password, new_password)
        post('/api/users/change-password', body: {
          currentPassword: current_password,
          newPassword: new_password
        })
      end

      def get_api_keys
        get('/api/users/api-keys')
      end

      def create_api_key(name, permissions: nil, expires_at: nil)
        body = { name: name }
        body[:permissions] = permissions if permissions
        body[:expiresAt] = expires_at if expires_at
        
        post('/api/users/api-keys', body: body)
      end

      def revoke_api_key(key_id)
        delete("/api/users/api-keys/#{key_id}")
      end

      def get_usage_stats(start_date: nil, end_date: nil)
        params = {}
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        get('/api/users/usage', params: params)
      end

      def get_billing_info
        get('/api/users/billing')
      end

      def update_billing_info(billing_data)
        put('/api/users/billing', body: billing_data)
      end

      def get_invoices(page: 1, limit: 20)
        response = get('/api/users/invoices', params: { page: page, limit: limit })
        paginated_response(response)
      end

      def get_invoice(invoice_id)
        get("/api/users/invoices/#{invoice_id}")
      end

      def download_invoice(invoice_id, format: 'pdf')
        get("/api/users/invoices/#{invoice_id}/download", params: { format: format })
      end

      def get_preferences
        get('/api/users/preferences')
      end

      def update_preferences(preferences)
        put('/api/users/preferences', body: preferences)
      end

      def get_notifications
        get('/api/users/notifications')
      end

      def update_notification_settings(settings)
        put('/api/users/notifications', body: settings)
      end

      def get_team_members
        get('/api/users/team')
      end

      def invite_team_member(email, role, permissions: nil)
        body = { email: email, role: role }
        body[:permissions] = permissions if permissions
        
        post('/api/users/team/invite', body: body)
      end

      def remove_team_member(member_id)
        delete("/api/users/team/#{member_id}")
      end

      def update_team_member(member_id, role: nil, permissions: nil)
        body = {}
        body[:role] = role if role
        body[:permissions] = permissions if permissions
        
        patch("/api/users/team/#{member_id}", body: body)
      end

      def get_audit_log(page: 1, limit: 50, filters: {})
        params = { page: page, limit: limit }.merge(filters)
        response = get('/api/users/audit-log', params: params)
        paginated_response(response)
      end

      def export_data(format: 'json')
        post('/api/users/export-data', body: { format: format })
      end

      def delete_account(confirmation)
        delete('/api/users/account', body: { confirmation: confirmation })
      end
    end
  end
end