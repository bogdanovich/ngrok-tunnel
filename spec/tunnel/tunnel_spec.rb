describe Ngrok::Tunnel do

  describe "Before start" do

    it "should not be running" do
      expect(Ngrok::Tunnel.running?).to be false
    end

    it "should be stopped" do
      expect(Ngrok::Tunnel.stopped?).to be true
    end

    it "should have status = :stopped" do
      expect(Ngrok::Tunnel.status).to eq :stopped
    end

  end

  describe "Run process" do

    before(:all) do
      Ngrok::Tunnel.start
    end

    after(:all) { Ngrok::Tunnel.stop }

    it "should be running" do
      expect(Ngrok::Tunnel.running?).to be true
    end

    it "should not be stopped" do
      expect(Ngrok::Tunnel.stopped?).to be false
    end

    it "should have status = :running" do
      expect(Ngrok::Tunnel.status).to eq :running
    end

    it "should still support port" do
      expect(Ngrok::Tunnel.port).to eq(3001)
    end

    it "should match local_addr" do
      expect(Ngrok::Tunnel.addr).to eq(3001)
    end

    it "should have valid ngrok_url" do
      expect(Ngrok::Tunnel.ngrok_url).to be =~ /http:\/\/.*ngrok\.io$/
    end

    it "should have valid ngrok_url_https" do
      expect(Ngrok::Tunnel.ngrok_url_https).to be =~ /https:\/\/.*ngrok\.io$/
    end

    it "should have pid > 0" do
      expect(Ngrok::Tunnel.pid).to be > 0
    end

  end

  describe "Custom log file" do
    it "should be able to use custom log file" do
      Ngrok::Tunnel.start(log: 'test.log')
      expect(Ngrok::Tunnel.running?).to eq true
      expect(Ngrok::Tunnel.log.path).to eq 'test.log'
      Ngrok::Tunnel.stop
      expect(Ngrok::Tunnel.stopped?).to eq true
    end
  end

  describe "Custom subdomain" do
    it "should fail without authtoken" do
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain')}.to raise_error Ngrok::Error
    end

    it "should fail with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(subdomain: 'test-subdomain', authtoken: 'incorrect_token')}.to raise_error Ngrok::Error
    end
  end

  describe "Custom hostname" do
    it "should fail without authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com')}.to raise_error Ngrok::Error
    end

    it "should fail with incorrect authtoken" do
      expect {Ngrok::Tunnel.start(hostname: 'example.com', authtoken: 'incorrect_token')}.to raise_error Ngrok::Error
    end
  end

  describe "Custom addr" do
    it "should map port param to addr" do
      port = 10010
      Ngrok::Tunnel.start(port: port)
      expect(Ngrok::Tunnel.addr).to eq port
      Ngrok::Tunnel.stop
    end

    it "should return just the port when the address contains a host" do
      addr = '192.168.0.5:10010'
      Ngrok::Tunnel.start(addr: addr)
      expect(Ngrok::Tunnel.port).to eq 10010
      Ngrok::Tunnel.stop
    end

    it "should support remote addresses" do
      addr = '192.168.0.5:10010'
      Ngrok::Tunnel.start(addr: addr)
      expect(Ngrok::Tunnel.addr).to eq addr
      Ngrok::Tunnel.stop
    end
  end

  describe "Custom parameters provided" do
    it "should not include the -inspect parameter when it is not provided" do
      Ngrok::Tunnel.start()
      expect(Ngrok::Tunnel.send(:ngrok_exec_params).include? "-inspect=").to be false
      Ngrok::Tunnel.stop
    end

    it "should include the -inspect parameter with the correct value when it is provided" do
      Ngrok::Tunnel.start(inspect: true)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params).include? "-inspect=true").to be true
      Ngrok::Tunnel.stop

      Ngrok::Tunnel.start(inspect: false)
      expect(Ngrok::Tunnel.send(:ngrok_exec_params).include? "-inspect=false").to be true
      Ngrok::Tunnel.stop
    end
  end

end
