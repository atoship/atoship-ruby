# frozen_string_literal: true

module Atoship
  module Services
    # Base service class for all API services
    class Base
      attr_reader :client

      def initialize(client)
        @client = client
      end

      protected

      def get(path, **options)
        client.get(path, **options)
      end

      def post(path, **options)
        client.post(path, **options)
      end

      def put(path, **options)
        client.put(path, **options)
      end

      def patch(path, **options)
        client.patch(path, **options)
      end

      def delete(path, **options)
        client.delete(path, **options)
      end

      def paginated_response(data)
        PaginatedResponse.new(data)
      end
    end

    # Paginated response wrapper
    class PaginatedResponse
      attr_reader :items, :total, :page, :limit, :has_more

      def initialize(data)
        @items = data['items'] || []
        @total = data['total'] || 0
        @page = data['page'] || 1
        @limit = data['limit'] || 20
        @has_more = data['hasMore'] || false
      end

      def has_more?
        @has_more
      end

      def next_page
        has_more? ? page + 1 : nil
      end
    end
  end
end