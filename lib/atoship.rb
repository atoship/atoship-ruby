# frozen_string_literal: true

require 'atoship/version'
require 'atoship/configuration'
require 'atoship/errors'
require 'atoship/client'

# Main module for atoship SDK
module Atoship
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def reset_configuration!
      self.configuration = Configuration.new
    end
  end
end

# Initialize default configuration
Atoship.configuration = Atoship::Configuration.new