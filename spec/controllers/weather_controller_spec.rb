require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "GET #index" do
    let(:zipcode) { "12345" }
    let(:invalid_zipcode) { "invalid" }
    let(:cache_key) { "weather_#{zipcode}" }
    let(:weather_data) { { "main" => { "temp" => 15.0 }, "weather" => [{ "description" => "clear sky" }] } }

    before do
      allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
      allow(FetchWeatherJob).to receive(:perform_later).and_return(true)
    end

    context "with valid ZIP code" do
      it "fetches weather data if it exists in cache" do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(weather_data)

        get :index, params: { zipcode: zipcode }

        expect(assigns(:weather_data)).to eq(weather_data)
        expect(assigns(:from_cache)).to be_truthy
      end

      it "enqueues a job to fetch weather data if it is not in cache" do
        get :index, params: { zipcode: zipcode }

        expect(FetchWeatherJob).to have_received(:perform_later).with(zipcode)
        expect(flash[:notice]).to eq("Weather data is being fetched for ZIP code #{zipcode}. Please refresh the page in a few moments.")
      end
    end

    context "with invalid ZIP code" do
      it "sets flash error message" do
        get :index, params: { zipcode: invalid_zipcode }

        expect(flash[:error]).to eq("Invalid ZIP code. Please enter a valid US ZIP code.")
      end
    end
  end
end