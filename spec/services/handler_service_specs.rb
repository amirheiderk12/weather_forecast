require 'rails_helper'

RSpec.describe HandlerService do
  let(:zipcode) { "12345" }
  let(:handler) { HandlerService.new(zipcode) }
  let(:cache_key) { "weather_#{zipcode}" }
  let(:weather_data) { { "main" => { "temp" => 15.0 }, "weather" => [{ "description" => "clear sky" }] } }

  describe "#process" do
    context "with valid ZIP code" do
      it "returns cached weather data if available" do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(weather_data)

        result = handler.process

        expect(result[:success]).to be_truthy
        expect(result[:data]).to eq(weather_data)
        expect(result[:from_cache]).to be_truthy
      end

      it "enqueues a job if weather data is not cached" do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow(FetchWeatherJob).to receive(:perform_later).and_return(true)

        result = handler.process

        expect(result[:success]).to be_falsey
        expect(result[:flash_type]).to eq(:notice)
        expect(result[:message]).to eq("Weather data is being fetched for ZIP code #{zipcode}. Please refresh the page in a few moments.")
        expect(FetchWeatherJob).to have_received(:perform_later).with(zipcode)
      end
    end

    context "with invalid ZIP code" do
      let(:invalid_zipcode) { "invalid" }
      let(:handler) { WeatherServiceHandler.new(invalid_zipcode) }

      it "returns an error response" do
        result = handler.process

        expect(result[:success]).to be_falsey
        expect(result[:flash_type]).to eq(:error)
        expect(result[:message]).to eq("Invalid ZIP code. Please enter a valid US ZIP code.")
      end
    end

    context "when job is not unique" do
      it "handles JobNotUnique exception gracefully" do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow(FetchWeatherJob).to receive(:perform_later).and_raise(FetchWeatherJob::JobNotUnique)

        result = handler.process

        expect(result[:success]).to be_falsey
        expect(result[:flash_type]).to eq(:notice)
        expect(result[:message]).to eq("Weather data for ZIP code #{zipcode} is already being fetched. Please refresh the page in a few moments.")
      end
    end

    context "when geocoding fails" do
      it "handles GeocodingFailed exception gracefully" do
        allow(Rails.cache).to receive(:read).with(cache_key).and_return(nil)
        allow(FetchWeatherJob).to receive(:perform_later).and_raise(FetchWeatherJob::GeocodingFailed)

        result = handler.process

        expect(result[:success]).to be_falsey
        expect(result[:flash_type]).to eq(:error)
        expect(result[:message]).to eq("Failed to fetch geocoding information for ZIP code #{zipcode}.")
      end
    end
  end
end