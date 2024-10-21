require "faraday"

class WeatherService
  API_URL = "https://api.openweathermap.org/data/2.5/weather".freeze
  FORECAST_API_URL = "https://api.openweathermap.org/data/2.5/forecast".freeze

  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
    @api_key = ENV["OPENWEATHER_API_KEY"]
  end

  def fetch_weather
    response = Faraday.get(API_URL, { lat: @lat, lon: @lon, units: "metric", appid: @api_key })
    JSON.parse(response.body) if response.success?
  end

  def fetch_forecast
    response = Faraday.get(FORECAST_API_URL, { lat: @lat, lon: @lon, units: "metric", appid: @api_key })
    JSON.parse(response.body) if response.success?
  end
end
