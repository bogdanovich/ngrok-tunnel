describe Ngrok::Tunnel do

  describe "Before start" do

    it "is not running" do
      expect(Ngrok::Tunnel.running?).to be false
    end

    it "is stopped" do
      expect(Ngrok::Tunnel.stopped?).to be true
    end

    it "has :stopped status" do
      expect(Ngrok::Tunnel.status).to eq :stopped
    end

  end

  describe "After start" do

    before(:all) { Ngrok::Tunnel.start }
    after(:all)  { Ngrok::Tunnel.stop }

    it "is running" do
      expect(Ngrok::Tunnel.running?).to be true
    end

    it "is not stopped" do
      expect(Ngrok::Tunnel.stopped?).to be false
    end

    it "has :running status" do
      expect(Ngrok::Tunnel.status).to eq :running
    end

    it "has correct port property" do
      expect(Ngrok::Tunnel.port).to eq(3001)
    end

    it "has correct addr property" do
      expect(Ngrok::Tunnel.addr).to eq(3001)
    end

    it "has valid ngrok_url" do
      expect(Ngrok::Tunnel.ngrok_url).to be =~ /http:\/\/.*ngrok\.io$/
    end

    it "has valid ngrok_url_https" do
      expect(Ngrok::Tunnel.ngrok_url_https).to be =~ /https:\/\/.*ngrok\.io$/
    end

    it "has correct pid property" do
      expect(Ngrok::Tunnel.pid).to be > 0
    end

  end

  describe "Custom log file" do
    it "uses custom log file" do
      Ngrok::Tunnel.start(log: 'test.log')
      expect(Ngrok::Tunnel.running?).to eq true
      expect(Ngrok::Tunnel.log.path).to eq 'test.log'
      Ngrok::Tunnel.stop
      expect(Ngrok::Tunnel.stopped?).to eq true
    end
  end

  describe "Custom subdomain" do
    it "fails without authtoken" do
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain')}.to raise_error Ngrok::Error
    end

    it "fails with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain', authtoken: 'incorrect_token')}.to raise_error Ngrok::Error
    end
  end

  describe "Custom hostname" do
    it "fails without authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com')}.to raise_error Ngrok::Error
    end

    it "fails with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com', authtoken: 'incorrect_token')}.to raise_error Ngrok::Error
    end
  end

  describe "Custom addr" do
    it "maps port param to addr" do
      port = 10010
      Ngrok::Tunnel.start(port: port)
      expect(Ngrok::Tunnel.addr).to eq port
      Ngrok::Tunnel.stop
    end

    it "returns just the port when the address contains a host" do
      addr = '192.168.0.5:10010'
      Ngrok::Tunnel.start(addr: addr)
      expect(Ngrok::Tunnel.port).to eq 10010
      Ngrok::Tunnel.stop
    end

    it "supports remote addresses" do
      addr = '192.168.0.5:10010'
      Ngrok::Tunnel.start(addr: addr)
      expect(Ngrok::Tunnel.addr).to eq addr
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom region" do
    it "doesn't include the -region parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("-region=")
      Ngrok::Tunnel.stop
    end

    it "includes the -region parameter with the correct value when it is provided" do
      region = 'eu'
      Ngrok::Tunnel.start(region: region)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-region=#{region}")
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom bind-tls" do
    it "doesn't include the -bind-tls parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("-bind-tls=")
      Ngrok::Tunnel.stop
    end

    it "includes the -bind-tls parameter with the correct value when it is true" do
      bind_tls = true
      Ngrok::Tunnel.start(bind_tls: bind_tls)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-bind-tls=#{bind_tls}")
      Ngrok::Tunnel.stop
    end

    it "includes the -bind-tls parameter with the correct value when it is false" do
      bind_tls = false
      Ngrok::Tunnel.start(bind_tls: bind_tls)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-bind-tls=#{bind_tls}")
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom host header" do
    before { expect(Ngrok::Tunnel).to receive(:fetch_urls) }

    it "doesn't include the -host-header parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("-host-header=")
      Ngrok::Tunnel.stop
    end

    it "includes the -host-header parameter with the correct value when it is provided" do
      host_header = 'foo.bar'
      Ngrok::Tunnel.start(host_header: host_header)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-host-header=#{host_header}")
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom parameters provided" do
    it "doesn't include the -inspect parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("-inspect=")
      Ngrok::Tunnel.stop
    end

    it "includes the -inspect parameter with the correct value when it is provided" do
      Ngrok::Tunnel.start(inspect: true)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-inspect=true")
      Ngrok::Tunnel.stop

      Ngrok::Tunnel.start(inspect: false)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("-inspect=false")
      Ngrok::Tunnel.stop
    end
  end

  describe '#start' do
    before { allow(Process).to receive(:kill) }
    after { Ngrok::Tunnel.stop }

    describe 'when persistence param is true' do
      it 'tries fetching params of an already running Ngrok and store Ngrok process data into a file ' do
        expect(Ngrok::Tunnel).to receive(:try_params_from_running_ngrok)
        expect(Ngrok::Tunnel).to receive(:spawn_new_ngrok).with(persistent_ngrok: true)
        expect(Ngrok::Tunnel).to receive(:store_new_ngrok_process)

        Ngrok::Tunnel.start(persistence: true)
      end
    end

    describe 'when persistence param is not true' do
      it "doesn't try to fetch params of an already running Ngrok" do
        expect(Ngrok::Tunnel).not_to receive(:try_params_from_running_ngrok)
        expect(Ngrok::Tunnel).to receive(:spawn_new_ngrok).with(persistent_ngrok: false)
        expect(Ngrok::Tunnel).not_to receive(:store_new_ngrok_process)

        Ngrok::Tunnel.start(persistence: false)
      end
    end

    describe 'when Ngrok::Tunnel is already running' do
      it "doesn't try to spawn a new Ngrok process" do
        allow(Ngrok::Tunnel).to receive(:stopped?).and_return(false)
        expect(Ngrok::Tunnel).not_to receive(:spawn_new_ngrok)

        Ngrok::Tunnel.start
      end
    end
  end
end
