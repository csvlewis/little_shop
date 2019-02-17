class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_cart

  helper_method :current_user, :current_admin?, :current_shopper?

  def set_cart
    @cart ||= Cart.new(session[:cart])
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_shopper?
    !(current_user && (current_user.admin? || current_user.merchant?))
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def require_registered
    render file: '/public/404' unless current_registered? || current_admin?
  end

  def current_registered?
    current_user && current_user.registered?
  end
end
