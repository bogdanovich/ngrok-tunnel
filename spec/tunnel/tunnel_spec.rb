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

    it "has nil ngrok_url" do
      expect(Ngrok::Tunnel.ngrok_url).to be nil
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
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain', redirect_stderr: true)}.to raise_error Ngrok::Error
    end

    it "fails with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain', authtoken: 'incorrect_token', redirect_stderr: true)}.to raise_error Ngrok::Error
    end
  end

  describe "Custom hostname" do
    it "fails without authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com', redirect_stderr: true)}.to raise_error Ngrok::Error
    end

    it "fails with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com', authtoken: 'incorrect_token', redirect_stderr: true)}.to raise_error Ngrok::Error
    end
  end

  describe "Custom addr" do
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
    it "doesn't include the --region parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("--region=")
      Ngrok::Tunnel.stop
    end

    it "includes the --region parameter with the correct value when it is provided" do
      region = 'eu'
      Ngrok::Tunnel.start(region: region)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--region=#{region}")
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom --scheme" do
    it "doesn't include the --scheme parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("--scheme=")
      Ngrok::Tunnel.stop
    end

    it "includes the --scheme parameter with the correct value when it is https" do
      scheme = "https"
      Ngrok::Tunnel.start(scheme: scheme)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--scheme=#{scheme}")
      Ngrok::Tunnel.stop
    end

    it "includes the --scheme parameter with the correct value when it is http" do
      scheme = "http"
      Ngrok::Tunnel.start(scheme: scheme)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--scheme=#{scheme}")
      expect(Ngrok::Tunnel.ngrok_url).to be =~ /http:\/\/.*ngrok\.io$/
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom host header" do
    it "doesn't include the --host-header parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("--host-header=")
      Ngrok::Tunnel.stop
    end

    it "includes the --host-header parameter with the correct value when it is provided" do
      host_header = 'foo.bar'
      Ngrok::Tunnel.start(host_header: host_header)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--host-header=#{host_header}")
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom parameters provided" do
    it "doesn't include the --inspect parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).not_to include("--inspect=")
      Ngrok::Tunnel.stop
    end

    it "includes the --inspect parameter with the correct value when it is provided" do
      Ngrok::Tunnel.start(inspect: true)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--inspect=true")
      Ngrok::Tunnel.stop

      Ngrok::Tunnel.start(inspect: false)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params)).to include("--inspect=false")
      Ngrok::Tunnel.stop
    end
  end
end
