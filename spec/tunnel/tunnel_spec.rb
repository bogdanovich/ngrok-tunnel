
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
      @local_port = 3001
      Ngrok::Tunnel.start(3001)
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

    it "should match local_port" do
      expect(Ngrok::Tunnel.local_port).to eq(@local_port)
    end

    it "should have valid ngrok_url" do
      expect(Ngrok::Tunnel.ngrok_url).to be =~ /http:\/\/.*ngrok.com$/
    end

    it "should have valid ngrok_url_https" do
      expect(Ngrok::Tunnel.ngrok_url_https).to be =~ /https:\/\/.*ngrok.com$/
    end

    it "should have pid > 0" do
      expect(Ngrok::Tunnel.pid).to be > 0
    end

    it "should present in process list" do
      expect(Ngrok::Tunnel.pid.to_s).to eq `pidof ngrok`.strip
    end

  end

end