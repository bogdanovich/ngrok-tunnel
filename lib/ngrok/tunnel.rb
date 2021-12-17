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
        # map old key 'port' to 'addr' to maintain backwards compatibility with versions 2.0.21 and earlier
        params[:addr] = params.delete(:port) if params.key?(:port)

        @params = {addr: 3001, timeout: 10, config: '/dev/null'}.merge!(params)
        @status = :stopped unless @status
      end

      def start(params = {})
        ensure_binary
        init(params)

        persistent_ngrok = @params[:persistence]
        if persistent_ngrok
          persistence_file = @params[:persistence_file] || '/tmp/ngrok-process'
          # Attempt to read the attributes of an existing process instead of starting a new process.
          begin
            state = JSON.parse(File.open(persistence_file, "rb").read)
            pid = state['pid']&.to_i
            running = begin
                        Process.kill(0, pid) if pid
                        true
                      rescue Errno::ESRCH
                        false
                      rescue Errno::EPERM
                        false
                      end

            if running
              @status = :running
              @pid = pid
              @ngrok_url = state['ngrok_url']
              @ngrok_url_https = state['ngrok_url_https']
            end
          rescue StandardError => e
            e
            # Catch all errors that could have happened while reading the file and just treat them as not finding an existing process.
          end
        end

        if stopped?
          @params[:log] = (@params[:log]) ? File.open(@params[:log], 'w+') : Tempfile.new('ngrok')
          if persistent_ngrok
            Process.spawn("exec nohup ngrok http #{ngrok_exec_params} &")
            @pid = (`ps ax | grep ngrok`).split(/\n/).find { |line| line.include?('ngrok http')}.split[0]
          else
            @pid = spawn("exec ngrok http #{ngrok_exec_params}")
            at_exit { Ngrok::Tunnel.stop }
          end

          fetch_urls
        end

        @status = :running

        if persistent_ngrok
          # Record the attributes of the new process so that it can be reused on a subsequent call.
          File.open(persistence_file, 'w') do |f|
            f.write({pid: @pid, ngrok_url: @ngrok_url, ngrok_url_https: @ngrok_url_https}.to_json)
          end
        end

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
        exec_params = "-log=stdout -log-level=debug "
        exec_params << "-bind-tls=#{@params[:bind_tls]} " if @params.has_key? :bind_tls
        exec_params << "-region=#{@params[:region]} " if @params[:region]
        exec_params << "-host-header=#{@params[:host_header]} " if @params[:host_header]
        exec_params << "-authtoken=#{@params[:authtoken]} " if @params[:authtoken]
        exec_params << "-subdomain=#{@params[:subdomain]} " if @params[:subdomain]
        exec_params << "-hostname=#{@params[:hostname]} " if @params[:hostname]
        exec_params << "-inspect=#{@params[:inspect]} " if @params.has_key? :inspect
        exec_params << "-config=#{@params[:config]} #{@params[:addr]} > #{@params[:log].path}"
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
        `ngrok version`
      rescue Errno::ENOENT
        raise Ngrok::NotFound, "Ngrok binary not found"
      end
    end

    init

  end
end
