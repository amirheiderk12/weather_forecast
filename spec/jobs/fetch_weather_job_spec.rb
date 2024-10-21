require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  let(:zipcode) { "49426" }

  describe "#perform" do
    it "writes weather data to cache if geocoding and API calls are successful" do
      allow(Geocoder).to receive(:search).and_return([ double(latitude: 42.8864, longitude: -85.5402, city: 'Hudsonville', state: 'Michigan', data: { 'address' => { 'county' => 'Ottawa' } }) ])
      allow_any_instance_of(WeatherService).to receive(:fetch_weather).and_return('main' => { 'temp' => 15.0 }, 'location' => { 'city' => 'Hudsonville', 'state' => 'Michigan' })
      allow_any_instance_of(WeatherService).to receive(:fetch_forecast).and_return('city' => { 'country' => 'US' }, 'list' => [])

      expect(Rails.cache).to receive(:write).with("weather_#{zipcode}", anything, expires_in: 30.minutes)
      FetchWeatherJob.perform_now(zipcode)
    end

    it "logs an error if geocoding fails" do
      allow(Geocoder).to receive(:search).and_return([])
      expect(Rails.logger).to receive(:error).with("Geocoding failed for ZIP code: #{zipcode}")
      FetchWeatherJob.perform_now(zipcode)
    end
  end
end
