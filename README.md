# atoship Ruby SDK

The official Ruby SDK for the atoship API. This SDK provides a comprehensive, idiomatic Ruby interface for all atoship shipping and logistics operations.

## Features

- 🚀 **Idiomatic Ruby**: Follows Ruby best practices and conventions
- 🔒 **Secure**: Built-in API key management and request signing
- 🔄 **Robust**: Automatic retries, timeout handling, and error management
- 📦 **Comprehensive**: Covers all atoship API endpoints
- 💎 **Ruby 2.7+**: Support for modern Ruby versions
- 🧪 **Well-tested**: Comprehensive test coverage with RSpec
- 📚 **Documented**: Full YARD documentation

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atoship'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install atoship
```

## Quick Start

```ruby
require 'atoship'

# Initialize the SDK
client = Atoship::Client.new(api_key: 'your-api-key')

# Create an order
order = client.orders.create(
  order_number: 'RUBY-ORDER-001',
  recipient_name: 'John Doe',
  recipient_street1: '123 Main St',
  recipient_city: 'San Francisco',
  recipient_state: 'CA',
  recipient_postal_code: '94105',
  recipient_country: 'US',
  recipient_phone: '415-555-0123',
  items: [
    {
      name: 'Ruby Programming Book',
      sku: 'BOOK-RUBY-001',
      quantity: 2,
      unit_price: 29.99,
      weight: 1.5,
      weight_unit: 'lb'
    }
  ]
)

puts "Order created: #{order.id}"
```

## Configuration

```ruby
# Global configuration
Atoship.configure do |config|
  config.api_key = ENV['ATOSHIP_API_KEY']
  config.base_url = 'https://api.atoship.com' # optional
  config.timeout = 30 # seconds
  config.max_retries = 3
  config.debug = true # Enable debug logging
end

# Or per-client configuration
client = Atoship::Client.new(
  api_key: 'your-api-key',
  timeout: 60,
  debug: Rails.env.development?
)
```

## Examples

### Get Shipping Rates

```ruby
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
    weight: 2.5,
    weight_unit: 'lb'
  }
)

rates.each do |rate|
  puts "#{rate.carrier} #{rate.service}: $#{rate.rate} (#{rate.delivery_days} days)"
end
```

### Purchase a Label

```ruby
label = client.shipping.purchase_label(
  rate_id: 'rate_123456',
  order_id: 'order_789012'
)

puts "Label URL: #{label.label_url}"
puts "Tracking: #{label.tracking_number}"
```

### Track a Package

```ruby
tracking = client.tracking.track('1Z999AA10123456784')

puts "Status: #{tracking.status}"
puts "Location: #{tracking.current_location}"

tracking.events.each do |event|
  puts "#{event.timestamp}: #{event.description} at #{event.location}"
end
```

### Validate an Address

```ruby
result = client.addresses.validate(
  name: 'Jane Smith',
  street1: '1600 Amphitheatre Parkway',
  city: 'Mountain View',
  state: 'CA',
  postal_code: '94043',
  country: 'US'
)

if result.valid?
  puts "✅ Address is valid"
else
  puts "❌ Address validation failed"
  puts "Errors: #{result.errors.join(', ')}"
  
  if result.suggestions.any?
    puts "Suggested addresses:"
    result.suggestions.each do |address|
      puts "  - #{address.street1}, #{address.city}, #{address.state} #{address.postal_code}"
    end
  end
end
```

## Error Handling

The SDK provides detailed error handling:

```ruby
begin
  order = client.orders.create(order_data)
rescue Atoship::ValidationError => e
  puts "Validation failed: #{e.message}"
  puts "Details: #{e.details}"
rescue Atoship::RateLimitError => e
  puts "Rate limit exceeded. Retry after: #{e.retry_after} seconds"
rescue Atoship::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Atoship::APIError => e
  puts "API error: #{e.message} (#{e.code})"
rescue Atoship::NetworkError => e
  puts "Network error: #{e.message}"
end
```

## Pagination

Handle paginated responses easily:

```ruby
# List orders with pagination
page = 1
loop do
  response = client.orders.list(page: page, limit: 100)
  
  response.items.each do |order|
    puts "Order: #{order.order_number}"
  end
  
  break unless response.has_more?
  page += 1
end
```

## Webhooks

```ruby
# Create a webhook
webhook = client.webhooks.create(
  url: 'https://your-app.com/webhooks/atoship',
  events: ['order.shipped', 'label.created', 'tracking.updated']
)

# Verify webhook signature (in your webhook handler)
class WebhooksController < ApplicationController
  def atoship
    signature = request.headers['X-Atoship-Signature']
    
    if Atoship::Webhook.verify_signature(request.body.read, signature, secret)
      # Process webhook
      event = JSON.parse(request.body.read)
      handle_event(event)
      head :ok
    else
      head :unauthorized
    end
  end
end
```

## Rails Integration

```ruby
# config/initializers/atoship.rb
Atoship.configure do |config|
  config.api_key = Rails.application.credentials.atoship_api_key
  config.logger = Rails.logger
  config.debug = Rails.env.development?
end

# app/services/shipping_service.rb
class ShippingService
  def self.ship_order(order)
    client = Atoship::Client.new
    
    # Create atoship order
    atoship_order = client.orders.create(
      order_number: order.number,
      recipient_name: order.customer_name,
      # ... other fields
    )
    
    # Get rates and purchase label
    rates = client.shipping.get_rates(...)
    best_rate = rates.min_by(&:rate)
    label = client.shipping.purchase_label(rate_id: best_rate.id)
    
    # Save tracking info
    order.update!(
      tracking_number: label.tracking_number,
      label_url: label.label_url
    )
  end
end
```

## Testing

Run the test suite:

```bash
bundle exec rspec
```

Run with coverage:

```bash
bundle exec rspec --format documentation
```

## Contributing

We welcome contributions! Please see our contributing guidelines for details.

## License

MIT License - see LICENSE file for details.

## Support

- Documentation: https://docs.atoship.com
- API Reference: https://api.atoship.com/docs
- Support: support@atoship.com