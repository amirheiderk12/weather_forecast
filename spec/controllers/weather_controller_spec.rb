require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "GET #index" do
    before do
      Rails.cache.clear
    end

    context "with valid ZIP code" do
      let(:valid_zipcode) { "49426" }

      it "fetches weather data if it exists in cache" do
        weather_data = { 'main' => { 'temp' => 15.0 }, 'weather' => [ { 'description' => 'clear sky' } ] }
        Rails.cache.write("weather_#{valid_zipcode}", weather_data)

        get :index, params: { zipcode: valid_zipcode }

        expect(assigns(:weather_data)).to eq(weather_data)
        expect(assigns(:from_cache)).to be true
      end

      it "queues FetchWeatherJob if weather data is not in cache" do
        expect(FetchWeatherJob).to receive(:perform_later).with(valid_zipcode)
        get :index, params: { zipcode: valid_zipcode }
      end
    end

    context "with invalid ZIP code" do
      it "sets flash error message" do
        get :index, params: { zipcode: "invalid" }
        expect(flash[:error]).to eq("Invalid ZIP code. Please enter a valid US ZIP code.")
      end
    end

    context "when an exception occurs" do
      it "handles the exception and sets flash error message" do
        allow(Rails.cache).to receive(:read).and_raise(StandardError, "Unexpected error")
        get :index, params: { zipcode: "49426" }
        expect(flash[:error]).to eq("Something went wrong. Please try again later.")
      end
    end
  end
end
