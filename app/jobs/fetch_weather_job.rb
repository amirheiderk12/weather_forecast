
class FetchWeatherJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(zipcode)
    location_data = geocode_zipcode(zipcode)
    if location_data
      weather_service = WeatherService.new(lat: location_data[:lat], lon: location_data[:lon])
      weather_data = weather_service.fetch_weather
      forecast_data = weather_service.fetch_forecast

      if weather_data && forecast_data
        weather_data["forecast"] = filter_forecast_for_usa(forecast_data)
        cache_key = "weather_#{zipcode}"
        Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
      end
    else
      Rails.logger.error "Geocoding failed for ZIP code: #{zipcode}"
    end
  end

  private

  def geocode_zipcode(zipcode)
    results = Geocoder.search(zipcode.to_s, params: { countrycodes: "us" })
    if results.any?
      { lat: results.first.latitude, lon: results.first.longitude }
    else
      nil
    end
  end

  def filter_forecast_for_usa(forecast_data)
    forecast_data if forecast_data["city"]["country"] == "US"
  end
end
