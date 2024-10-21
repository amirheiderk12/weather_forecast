class WeatherDecorator
  def initialize(weather_data)
    @weather_data = weather_data
  end

  def display_weather
    "<div class='current-weather' style='padding: 15px; background-color: #e0f7fa; border-radius: 8px; text-align: center; margin-bottom: 20px;'>
       <h3>Current Weather for #{@weather_data['location']['city'] || @weather_data['name']}, #{@weather_data['location'][:state]}</h3>
       <p><strong>County:</strong> #{@weather_data['location'][:county]}</p>
       <p><strong>Temperature:</strong> #{@weather_data['main']['temp']}°C</p>
       <p><strong>High:</strong> #{@weather_data['main']['temp_max']}°C</p>
       <p><strong>Low:</strong> #{@weather_data['main']['temp_min']}°C</p>
       <p><strong>Weather Outlook:</strong> #{@weather_data['weather'][0]['description']}</p>
     </div>".html_safe
  end

  def display_forecast
    return unless @weather_data["forecast"]

    grouped_forecast = @weather_data["forecast"]["list"].group_by { |forecast| forecast["dt_txt"].to_date }

    grouped_forecast.map do |date, forecasts|
      daily_cards = forecasts.map do |forecast|
        "<div class='forecast-card' style='display: inline-block; margin: 5px; padding: 10px; background-color: #f0f0f0; border-radius: 8px; width: 130px; text-align: center;'>
          <p>Time: #{forecast['dt_txt'].to_time.strftime('%l:%M %p')}</p>
          <p>Temp: #{forecast['main']['temp']}°C</p>
          <p>#{forecast['weather'][0]['description'].capitalize}</p>
        </div>"
      end.join

      "<div class='daily-forecast' style='margin-bottom: 20px;'>
        <h4>#{date.strftime('%A, %b %d, %Y')}</h4>
        #{daily_cards}
      </div>"
    end.join.html_safe
  end
end
