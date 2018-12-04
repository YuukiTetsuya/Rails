class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def home
    render html: "こんにちは世界"
  end
end
