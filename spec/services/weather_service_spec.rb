require 'rails_helper'

RSpec.describe WeatherService do
  let(:lat) { 42.8864 }
  let(:lon) { -85.5402 }
  let(:service) { described_class.new(lat: lat, lon: lon) }

  describe "#fetch_weather" do
    it "returns weather data from API" do
      response = { 'main' => { 'temp' => 15.0 }, 'location' => { 'city' => 'Hudsonville', 'state' => 'Michigan' } }.to_json
      stub_request(:get, /api.openweathermap.org/).to_return(status: 200, body: response)

      result = service.fetch_weather
      expect(result['main']['temp']).to eq(15.0)
      expect(result['location']['city']).to eq('Hudsonville')
      expect(result['location']['state']).to eq('Michigan')
    end

    it "handles API failure gracefully" do
      stub_request(:get, /api.openweathermap.org/).to_return(status: 500)

      expect { service.fetch_weather }.not_to raise_error
    end
  end

  describe "#fetch_forecast" do
    it "returns forecast data from API" do
      response = { 'list' => [ { 'dt_txt' => '2024-10-22 12:00:00', 'main' => { 'temp' => 10.0 }, 'weather' => [ { 'description' => 'clear sky' } ] } ] }.to_json
      stub_request(:get, /api.openweathermap.org/).to_return(status: 200, body: response)

      result = service.fetch_forecast
      expect(result['list'].first['main']['temp']).to eq(10.0)
      expect(result['list'].first['weather'].first['description']).to eq('clear sky')
    end

    it "handles API failure gracefully" do
      stub_request(:get, /api.openweathermap.org/).to_return(status: 500)

      expect { service.fetch_forecast }.not_to raise_error
    end
  end
end
