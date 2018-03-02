require 'test_helper'
require 'open3'

module Sidekiq
  describe Lock do
    it 'automatically loads lock middleware for sidekiq server' do
      cmd = 'sidekiq -r ./test/test_workers.rb -v'
      buffer = ''

      # very not fancy (https://78.media.tumblr.com/tumblr_lzkpw7DAl21qhy6c9o2_400.gif)
      # solution, but should do the job
      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        begin
          Timeout.timeout(5) do
            until stdout.eof? do
              buffer << stdout.read_nonblock(16)
            end
          end
        rescue Timeout::Error
          Process.kill('KILL', thread.pid)
        end
      end

      assert_match(/Server Middleware:\s*Sidekiq::Lock::Middleware/i, buffer)
    end
  end
end
