class WeatherController < ApplicationController
  def index
    if params[:zipcode].present?
      zipcode = params[:zipcode].strip
      if valid_zipcode?(zipcode)
        cache_key = "weather_#{zipcode}"
        weather_data = Rails.cache.read(cache_key)

        if weather_data
          @weather_data = weather_data
          @from_cache = true
        else
          FetchWeatherJob.perform_later(zipcode)
          flash[:notice] = "Weather data is being fetched for ZIP code #{zipcode}. Please refresh the page in a few moments."
        end
      else
        flash[:error] = "Invalid ZIP code. Please enter a valid US ZIP code."
      end
    end
  end

  private

  def valid_zipcode?(zipcode)
    zipcode.match?(/\A\d{5}(-\d{4})?\z/)
  end
end
