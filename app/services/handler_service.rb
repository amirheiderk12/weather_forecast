class HandlerService
  def initialize(zipcode)
    @zipcode = zipcode
  end

  def process
    return invalid_zipcode_response unless valid_zipcode?

    weather_data = read_from_cache

    if weather_data
      cached_weather_response(weather_data)
    else
      enqueue_weather_job
    end
  end

  private

  def valid_zipcode?
    @zipcode.match?(/\A\d{5}(-\d{4})?\z/)
  end

  def read_from_cache
    cache_key = "weather_#{@zipcode}"
    Rails.cache.read(cache_key)
  end

  def cached_weather_response(weather_data)
    {
      success: true,
      data: weather_data,
      from_cache: true
    }
  end

  def enqueue_weather_job
    begin
      FetchWeatherJob.perform_later(@zipcode)
      {
        success: false,
        flash_type: :notice,
        message: "Weather data is being fetched for ZIP code #{@zipcode}. Please refresh the page in a few moments."
      }
    rescue FetchWeatherJob::JobNotUnique
      {
        success: false,
        flash_type: :notice,
        message: "Weather data for ZIP code #{@zipcode} is already being fetched. Please refresh the page in a few moments."
      }
    rescue FetchWeatherJob::GeocodingFailed
      {
        success: false,
        flash_type: :error,
        message: "Failed to fetch geocoding information for ZIP code #{@zipcode}."
      }
    end
  end

  def invalid_zipcode_response
    {
      success: false,
      flash_type: :error,
      message: "Invalid ZIP code. Please enter a valid US ZIP code."
    }
  end
end