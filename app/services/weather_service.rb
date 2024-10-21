# app/services/weather_service.rb
require 'faraday'

class WeatherService
  API_URL = 'https://api.openweathermap.org/data/2.5/weather'.freeze

  def initialize(address)
    @address = address
    @api_key = ENV['OPENWEATHER_API_KEY'] # Store your API key in .env
  end

  def fetch_weather
    coordinates = geocode_address(@address)
    if coordinates
      response = Faraday.get(API_URL, { lat: coordinates[:lat], lon: coordinates[:lon], units: 'metric', appid: @api_key })
      JSON.parse(response.body) if response.success?
    else
      nil
    end
  end

  private

  # Simple geocode method, here you can implement actual geocoding if needed
  def geocode_address(address)
    # Example static coordinates for simplicity; you can integrate with a geocoding service
    {
      lat: 37.7749,  # Example lat for San Francisco
      lon: -122.4194 # Example lon for San Francisco
    }
  end
end
