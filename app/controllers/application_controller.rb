class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from StandardError, with: :handle_exception

  private

  def handle_exception(exception)
    Rails.logger.error "An error occurred: #{exception.message}"
    flash[:error] = "Something went wrong. Please try again later."
    redirect_to root_path
  end
end
