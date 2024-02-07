require 'test_helper'
require 'open3'

module Sidekiq
  describe Lock do
    it 'automatically loads lock middleware for sidekiq server' do
      skip 'Sidekiq 7+ does not print out middleware information' if Sidekiq::VERSION >= '7'

      cmd = 'sidekiq -r ./test/test_workers.rb -v'
      buffer_out = ''
      buffer_err = ''

      # very not fancy (https://78.media.tumblr.com/tumblr_lzkpw7DAl21qhy6c9o2_400.gif)
      # solution, but should do the job
      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        begin
          Timeout.timeout(5) do
            until stderr.eof? do
              buffer_err << stderr.read_nonblock(16)
            end
            until stdout.eof? do
              buffer_out << stdout.read_nonblock(16)
            end
          end

        rescue Timeout::Error
          Process.kill('KILL', thread.pid)
        end
      end

      assert_empty(buffer_err)
      assert_match(/\s?Middleware:.*Sidekiq::Lock::Middleware/i, buffer_out)
    end
  end
end
