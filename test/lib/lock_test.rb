# frozen_string_literal: true

require 'test_helper'
require 'open3'

module Sidekiq
  describe Lock do
    it 'automatically loads lock middleware for sidekiq server' do
      script = <<~'RUBY'
        require 'sidekiq/cli'
        require 'sidekiq-lock'

        chain = if Sidekiq.respond_to?(:default_configuration)
          Sidekiq.default_configuration.server_middleware
        else
          Sidekiq.server_middleware
        end

        abort 'lock middleware was not registered' unless chain.exists?(Sidekiq::Lock::Middleware)
      RUBY

      _stdout, stderr, status = Open3.capture3(Gem.ruby, '-Ilib', '-e', script)

      assert status.success?, stderr
    end
  end
end
