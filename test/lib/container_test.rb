require 'test_helper'
require 'open3'

module Sidekiq
  module Lock
    describe Container do
      it 'stores and fetches given value under Thread.current' do
        begin
          container = Sidekiq::Lock::Container.new
          thread_key = Sidekiq::Lock::Container::THREAD_KEY

          Thread.current[thread_key] = 'value'
          assert_equal 'value', container.fetch

          container.store 'new-value'
          assert_equal Thread.current[thread_key], 'new-value'
        ensure
          Thread.current[thread_key] = nil
        end
      end
    end
  end
end
