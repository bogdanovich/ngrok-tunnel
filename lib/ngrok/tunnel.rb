require "ngrok/tunnel/version"
require "tempfile"

module Ngrok

  class NotFound < StandardError; end
  class FetchUrlError < StandardError; end

  class Tunnel
    
    class << self
      attr_reader :pid, :local_port, :ngrok_url, :ngrok_url_https, :log_file, :status

      def init
        @status = :stopped
      end

      def start(port, options = {})
        options[:timeout] ||= 10
        @options = options

        ensure_binary

        @local_port = port.to_i
        @log_file   = Tempfile.new('ngrok')
        
        @pid = spawn("exec ngrok -log=stdout #{@local_port} > #{@log_file.path}")
        at_exit { Ngrok::Tunnel.stop }      
        @status = :running
        fetch_urls
      end

      def stop
        if running?
          Process.kill(9, @pid)
          @ngrok_url = @ngrok_url_https = @pid = nil
          @status = :stopped
        end
      end

      def running?
        @status == :running
      end

      def stopped?
        @status == :stopped
      end

      def inherited(subclass)
        init
      end

      private

      def fetch_urls
        @options[:timeout].times do
          @ngrok_url, @ngrok_url_https = @log_file.read.scan(/"Url":"([^"]+)"/).flatten
          return @ngrok_url if @ngrok_url
          sleep 1
          @log_file.rewind
        end
        raise FetchUrlError, "Unable to fetch external url"
        @ngrok_url
      end

      def ensure_binary
        `ngrok version`
      rescue Errno::ENOENT
        raise Ngrok::NotFound, "Ngrok binary not found"
      end
    end

    init

  end
end