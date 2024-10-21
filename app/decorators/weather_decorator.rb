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
    forecast_list = @weather_data["forecast"]["list"].first(5)
    forecast_list.map do |forecast|
      "<div class='forecast-card' style='display: inline-block; margin: 10px; padding: 15px; background-color: #f0f0f0; border-radius: 8px; width: 150px; text-align: center;'>
         <h4>#{forecast['dt_txt'].to_date.strftime('%A')}</h4>
         <p>#{forecast['dt_txt'].to_date.strftime('%b %d, %Y')}</p>
         <p>Temp: #{forecast['main']['temp']}°C</p>
         <p>#{forecast['weather'][0]['description'].capitalize}</p>
       </div>"
    end.join.html_safe
  end
end
