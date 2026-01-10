# frozen_string_literal: true

require 'atoship/services/base'

module Atoship
  module Services
    # Orders service for managing orders
    class Orders < Base
      def create(order_data)
        post('/api/orders', body: order_data)
      end

      def get(order_id)
        get("/api/orders/#{order_id}")
      end

      def list(page: 1, limit: 20, status: nil, search: nil)
        params = { page: page, limit: limit }
        params[:status] = status if status
        params[:search] = search if search
        
        response = get('/api/orders', params: params)
        paginated_response(response)
      end

      def update(order_id, update_data)
        patch("/api/orders/#{order_id}", body: update_data)
      end

      def delete(order_id)
        delete("/api/orders/#{order_id}")
      end

      def batch_create(orders)
        post('/api/orders/batch', body: { orders: orders })
      end

      def merge(order_ids)
        post('/api/orders/merge', body: { orderIds: order_ids })
      end

      def cancel(order_id, reason: nil)
        post("/api/orders/#{order_id}/cancel", body: { reason: reason })
      end

      def archive(order_id)
        post("/api/orders/#{order_id}/archive")
      end

      def unarchive(order_id)
        post("/api/orders/#{order_id}/unarchive")
      end

      def duplicate(order_id)
        post("/api/orders/#{order_id}/duplicate")
      end

      def search(query, filters: {})
        params = { q: query }.merge(filters)
        response = get('/api/orders/search', params: params)
        paginated_response(response)
      end

      def export(format: 'csv', filters: {})
        params = { format: format }.merge(filters)
        get('/api/orders/export', params: params)
      end

      def import(file_path, format: 'csv')
        File.open(file_path, 'rb') do |file|
          post('/api/orders/import', 
               body: { file: file, format: format },
               headers: { 'Content-Type': 'multipart/form-data' })
        end
      end

      def add_note(order_id, note, internal: false)
        post("/api/orders/#{order_id}/notes", body: {
          note: note,
          internal: internal
        })
      end

      def get_notes(order_id)
        get("/api/orders/#{order_id}/notes")
      end

      def add_tag(order_id, tag)
        post("/api/orders/#{order_id}/tags", body: { tag: tag })
      end

      def remove_tag(order_id, tag)
        delete("/api/orders/#{order_id}/tags/#{tag}")
      end

      def get_history(order_id)
        get("/api/orders/#{order_id}/history")
      end
    end
  end
end