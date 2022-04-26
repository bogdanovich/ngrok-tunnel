require "ngrok/tunnel/version"
require "tempfile"

module Ngrok

  class NotFound < StandardError; end
  class FetchUrlError < StandardError; end
  class Error < StandardError; end

  class Tunnel

    class << self
      attr_reader :pid, :ngrok_url, :ngrok_url_https, :status

      def init(params = {})
        @params = {addr: 3001, timeout: 10, config: create_empty_config_file.path}.merge(params)
        @status = :stopped unless @status
      end

      def start(params = {})
        ensure_binary
        raise Ngrok::NotFound, "Ngrok version >= 3 required" if pre_v3?

        init(params)

        if stopped?
          @params[:log] = (@params[:log]) ? File.open(@params[:log], 'w+') : Tempfile.new('ngrok')
          @pid = spawn("exec ngrok http " + ngrok_exec_params)
          at_exit { Ngrok::Tunnel.stop }
          fetch_urls
        end

        @status = :running
        @ngrok_url
      end

      def stop
        if running?
          Process.kill(9, @pid)
          @ngrok_url = @ngrok_url_https = @pid = nil
          @status = :stopped
        end
        @status
      end

      def running?
        @status == :running
      end

      def stopped?
        @status == :stopped
      end

      def addr
        @params[:addr]
      end

      def port
        return addr if addr.is_a?(Numeric)
        addr.split(":").last.to_i
      end

      def log
        @params[:log]
      end

      def subdomain
        @params[:subdomain]
      end

      def authtoken
        @params[:authtoken]
      end

      def inherited(subclass)
        init
      end

      private

      def ngrok_exec_params
        exec_params = "--log=stdout --log-level=debug "
        exec_params << "--scheme=#{@params[:scheme]} " if @params.has_key? :scheme
        exec_params << "--region=#{@params[:region]} " if @params[:region]
        exec_params << "--host-header=#{@params[:host_header]} " if @params[:host_header]
        exec_params << "--authtoken=#{@params[:authtoken]} " if @params[:authtoken]
        exec_params << "--subdomain=#{@params[:subdomain]} " if @params[:subdomain]
        exec_params << "--hostname=#{@params[:hostname]} " if @params[:hostname]
        exec_params << "--inspect=#{@params[:inspect]} " if @params.has_key? :inspect
        exec_params << "--config=#{@params[:config]} #{@params[:addr]} > #{@params[:log].path}"
        exec_params << " 2>&1" if @params[:redirect_stderr]

        exec_params
      end

      def fetch_urls
        @params[:timeout].times do
          log_content = @params[:log].read
          result = log_content.scan(/URL:(.+)\sProto:(http|https)\s/)
          if !result.empty?
            result = Hash[*result.flatten].invert
            @ngrok_url = result['http']
            @ngrok_url_https = result['https']
            return @ngrok_url if @ngrok_url
            return @ngrok_url_https if @ngrok_url_https
          end

          error = log_content.scan(/msg="command failed" err="([^"]+)"/).flatten
          unless error.empty?
            self.stop
            raise Ngrok::Error, error.first
          end

          sleep 1
          @params[:log].rewind
        end
        raise FetchUrlError, "Unable to fetch external url"
        @ngrok_url
      end

      def ensure_binary
        @version = `ngrok version`
      rescue Errno::ENOENT
        raise Ngrok::NotFound, "Ngrok binary not found"
      end

      def pre_v3?
        /^ngrok version [012]\./.match?(@version)
      end

      def create_empty_config_file
        tmp = Tempfile.new('ngrok_config-')
        tmp << "version: ""2""\n"
        tmp.flush
        tmp.close

        tmp
      end
    end

    init

  end
end
