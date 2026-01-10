#!/usr/bin/env ruby
# frozen_string_literal: true

require 'atoship'
require 'json'

# Configure the SDK globally
Atoship.configure do |config|
  config.api_key = ENV['ATOSHIP_API_KEY'] || 'your-api-key'
  config.base_url = 'https://api.atoship.com'
  config.debug = true
end

# Initialize client
client = Atoship::Client.new

puts "=== atoship Ruby SDK Basic Example ==="
puts

begin
  # Example 1: Create an order
  puts "1. Creating an order..."
  order = client.orders.create(
    order_number: 'RUBY-ORDER-001',
    recipient_name: 'John Doe',
    recipient_street1: '123 Main St',
    recipient_city: 'San Francisco',
    recipient_state: 'CA',
    recipient_postal_code: '94105',
    recipient_country: 'US',
    recipient_phone: '415-555-0123',
    recipient_email: 'john.doe@example.com',
    items: [
      {
        name: 'Ruby Programming Book',
        sku: 'BOOK-RUBY-001',
        quantity: 2,
        unit_price: 29.99,
        weight: 1.5,
        weight_unit: 'lb'
      },
      {
        name: 'Rails Framework Guide',
        sku: 'BOOK-RAILS-001',
        quantity: 1,
        unit_price: 34.99,
        weight: 1.8,
        weight_unit: 'lb'
      }
    ]
  )
  puts "✅ Order created successfully: #{order['id']}"
  puts

  # Example 2: Get shipping rates
  puts "2. Getting shipping rates..."
  rates = client.shipping.get_rates(
    from_address: {
      street1: '456 Oak Ave',
      city: 'Los Angeles',
      state: 'CA',
      postal_code: '90001',
      country: 'US'
    },
    to_address: {
      street1: '789 Pine St',
      city: 'New York',
      state: 'NY',
      postal_code: '10001',
      country: 'US'
    },
    parcel: {
      length: 10,
      width: 8,
      height: 6,
      dim_unit: 'in',
      weight: 3.3,
      weight_unit: 'lb'
    }
  )
  
  puts "Found #{rates.length} shipping rates:"
  rates.each do |rate|
    puts "  - #{rate.carrier} #{rate.service}: $#{'%.2f' % rate.rate} (#{rate.delivery_days} days)"
    if rate.discounted?
      puts "    💰 Save #{rate.discount_percentage}% off retail price!"
    end
  end
  puts

  # Example 3: Compare rates to find best option
  puts "3. Comparing rates..."
  comparison = client.shipping.compare_rates(
    from_address: {
      street1: '456 Oak Ave',
      city: 'Los Angeles',
      state: 'CA',
      postal_code: '90001',
      country: 'US'
    },
    to_address: {
      street1: '789 Pine St',
      city: 'New York',
      state: 'NY',
      postal_code: '10001',
      country: 'US'
    },
    parcel: {
      length: 10,
      width: 8,
      height: 6,
      dim_unit: 'in',
      weight: 3.3,
      weight_unit: 'lb'
    }
  )
  
  if comparison.has_rates?
    puts "💵 Cheapest: #{comparison.cheapest.carrier} - $#{'%.2f' % comparison.cheapest.rate}"
    puts "⚡ Fastest: #{comparison.fastest.carrier} - #{comparison.fastest.delivery_days} days"
    puts "⭐ Best Value: #{comparison.best_value.carrier} - $#{'%.2f' % comparison.best_value.rate} in #{comparison.best_value.delivery_days} days"
  end
  puts

  # Example 4: Validate an address
  puts "4. Validating an address..."
  validation = client.addresses.validate(
    name: 'Jane Smith',
    street1: '1600 Amphitheatre Parkway',
    city: 'Mountain View',
    state: 'CA',
    postal_code: '94043',
    country: 'US'
  )
  
  if validation.valid?
    puts "✅ Address is valid"
    if validation.normalized_address
      puts "Normalized: #{validation.normalized_address['street1']}, #{validation.normalized_address['city']}, #{validation.normalized_address['state']} #{validation.normalized_address['postal_code']}"
    end
  else
    puts "❌ Address validation failed"
    if validation.has_errors?
      puts "Errors:"
      validation.errors.each { |error| puts "  - #{error}" }
    end
    if validation.has_suggestions?
      puts "Suggested addresses:"
      validation.suggestions.each do |addr|
        puts "  - #{addr['street1']}, #{addr['city']}, #{addr['state']} #{addr['postal_code']}"
      end
    end
  end
  puts

  # Example 5: Track a package
  puts "5. Tracking a package..."
  begin
    tracking = client.tracking.track('1Z999AA10123456784')
    
    puts "Package Status: #{tracking.status}"
    puts "Current Location: #{tracking.current_location}"
    
    if tracking.delivered?
      puts "✅ Package delivered!"
      puts "Delivered at: #{tracking.actual_delivery}"
      puts "Signature: #{tracking.signature}" if tracking.signature
    elsif tracking.estimated_delivery
      puts "📦 Estimated delivery: #{tracking.estimated_delivery}"
    end
    
    if tracking.in_transit?
      puts "Package has been in transit for #{tracking.days_in_transit} days"
    end
    
    if tracking.events.any?
      puts "\nRecent tracking events:"
      tracking.events.first(3).each do |event|
        puts "  #{event.timestamp}: #{event.description}"
        puts "    Location: #{event.location}" if event.location
      end
    end
  rescue Atoship::NotFoundError => e
    puts "⚠️  Could not track package: #{e.message}"
  end
  puts

  # Example 6: Create a webhook
  puts "6. Creating a webhook..."
  webhook = client.webhooks.create(
    'https://your-app.com/webhooks/atoship',
    ['order.shipped', 'label.created', 'tracking.updated'],
    active: true
  )
  puts "✅ Webhook created: #{webhook['id']}"
  puts "   URL: #{webhook['url']}"
  puts "   Events: #{webhook['events'].join(', ')}"
  puts

  # Example 7: List recent orders
  puts "7. Listing recent orders..."
  orders = client.orders.list(page: 1, limit: 5)
  
  puts "Found #{orders.total} total orders"
  puts "Showing page #{orders.page} of #{(orders.total.to_f / orders.limit).ceil}"
  
  orders.items.each do |order_item|
    puts "  - #{order_item['orderNumber']}: #{order_item['recipientName']} (#{order_item['status']})"
  end
  
  if orders.has_more?
    puts "  ... more orders available on page #{orders.next_page}"
  end
  puts

  # Example 8: Get user profile and usage stats
  puts "8. Getting user profile and usage..."
  profile = client.users.get_profile
  puts "User: #{profile['name']} (#{profile['email']})"
  puts "Account Type: #{profile['accountType']}"
  
  usage = client.users.get_usage_stats
  puts "API Usage:"
  puts "  - Orders Created: #{usage['ordersCreated']}"
  puts "  - Labels Purchased: #{usage['labelsPurchased']}"
  puts "  - Total Shipping Cost: $#{'%.2f' % usage['totalShippingCost']}"
  puts

  puts "=== Example completed successfully! ==="

rescue Atoship::AuthenticationError => e
  puts "❌ Authentication failed: #{e.message}"
  puts "Please check your API key"
rescue Atoship::ValidationError => e
  puts "❌ Validation error: #{e.message}"
  if e.validation_errors
    puts "Details:"
    e.validation_errors.each { |field, error| puts "  - #{field}: #{error}" }
  end
rescue Atoship::RateLimitError => e
  puts "❌ Rate limit exceeded: #{e.message}"
  puts "Retry after: #{e.retry_after} seconds" if e.retry_after
rescue Atoship::NetworkError => e
  puts "❌ Network error: #{e.message}"
  puts "Please check your internet connection"
rescue Atoship::APIError => e
  puts "❌ API error: #{e.message}"
  puts "Status code: #{e.status_code}" if e.status_code
rescue => e
  puts "❌ Unexpected error: #{e.message}"
  puts e.backtrace.first(5)
end