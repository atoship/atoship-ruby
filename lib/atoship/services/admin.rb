# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Admin service for administrative operations
    class Admin < Base
      def get_statistics(start_date: nil, end_date: nil, metrics: nil)
        params = {}
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        params[:metrics] = metrics if metrics
        
        get('/api/admin/statistics', params: params)
      end

      def get_system_health
        get('/api/admin/health')
      end

      def get_system_status
        get('/api/admin/status')
      end

      def list_users(page: 1, limit: 20, search: nil, role: nil)
        params = { page: page, limit: limit }
        params[:search] = search if search
        params[:role] = role if role
        
        response = get('/api/admin/users', params: params)
        paginated_response(response)
      end

      def get_user(user_id)
        get("/api/admin/users/#{user_id}")
      end

      def create_user(user_data)
        post('/api/admin/users', body: user_data)
      end

      def update_user(user_id, user_data)
        patch("/api/admin/users/#{user_id}", body: user_data)
      end

      def delete_user(user_id)
        delete("/api/admin/users/#{user_id}")
      end

      def suspend_user(user_id, reason: nil, duration: nil)
        body = {}
        body[:reason] = reason if reason
        body[:duration] = duration if duration
        
        post("/api/admin/users/#{user_id}/suspend", body: body)
      end

      def unsuspend_user(user_id)
        post("/api/admin/users/#{user_id}/unsuspend")
      end

      def reset_user_password(user_id)
        post("/api/admin/users/#{user_id}/reset-password")
      end

      def get_audit_logs(page: 1, limit: 50, filters: {})
        params = { page: page, limit: limit }.merge(filters)
        response = get('/api/admin/audit-logs', params: params)
        paginated_response(response)
      end

      def get_error_logs(page: 1, limit: 50, level: nil, start_date: nil, end_date: nil)
        params = { page: page, limit: limit }
        params[:level] = level if level
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        response = get('/api/admin/error-logs', params: params)
        paginated_response(response)
      end

      def get_api_usage(user_id: nil, start_date: nil, end_date: nil, group_by: 'day')
        params = { groupBy: group_by }
        params[:userId] = user_id if user_id
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        get('/api/admin/api-usage', params: params)
      end

      def get_revenue_report(start_date: nil, end_date: nil, group_by: 'day')
        params = { groupBy: group_by }
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        get('/api/admin/revenue', params: params)
      end

      def get_carrier_performance(carrier: nil, start_date: nil, end_date: nil)
        params = {}
        params[:carrier] = carrier if carrier
        params[:startDate] = start_date if start_date
        params[:endDate] = end_date if end_date
        
        get('/api/admin/carrier-performance', params: params)
      end

      def broadcast_message(message, type: 'info', expires_at: nil)
        body = { message: message, type: type }
        body[:expiresAt] = expires_at if expires_at
        
        post('/api/admin/broadcast', body: body)
      end

      def clear_cache(cache_type: nil)
        params = cache_type ? { type: cache_type } : {}
        post('/api/admin/cache/clear', params: params)
      end

      def run_maintenance(task)
        post('/api/admin/maintenance', body: { task: task })
      end

      def export_data(type, format: 'csv', filters: {})
        params = { type: type, format: format }.merge(filters)
        get('/api/admin/export', params: params)
      end

      def import_data(type, file_path, format: 'csv')
        File.open(file_path, 'rb') do |file|
          post('/api/admin/import',
               body: { type: type, file: file, format: format },
               headers: { 'Content-Type': 'multipart/form-data' })
        end
      end

      def get_settings
        get('/api/admin/settings')
      end

      def update_settings(settings)
        put('/api/admin/settings', body: settings)
      end

      def get_feature_flags
        get('/api/admin/feature-flags')
      end

      def update_feature_flag(flag_name, enabled: nil, rollout_percentage: nil)
        body = {}
        body[:enabled] = enabled unless enabled.nil?
        body[:rolloutPercentage] = rollout_percentage if rollout_percentage
        
        patch("/api/admin/feature-flags/#{flag_name}", body: body)
      end

      def get_rate_limits
        get('/api/admin/rate-limits')
      end

      def update_rate_limit(user_id, limit, window: '1h')
        put("/api/admin/rate-limits/#{user_id}", body: {
          limit: limit,
          window: window
        })
      end
    end
  end
end