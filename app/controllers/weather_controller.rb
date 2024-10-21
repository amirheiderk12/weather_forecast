class WeatherController < ApplicationController
  def index
    if params[:zipcode].present?
      weather_service = HandlerService.new(params[:zipcode].strip)
      result = weather_service.process

      if result[:success]
        @weather_data = result[:data]
        @from_cache = result[:from_cache]
      else
        flash[result[:flash_type]] = result[:message]
      end
    end
  end
end