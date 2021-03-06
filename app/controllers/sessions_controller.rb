class SessionsController < ApplicationController
  def new
    if current_user
      flash[:info] = "You are already logged in"
      redirect_user
    end
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password]) && !user.disabled
      session[:user_id] = user.id
      flash[:success] = "You are now logged in"
      redirect_user
    else
      flash[:danger] = "Invalid email and/or password"
      render :new
    end
  end

  def destroy
    session.clear
    flash[:success] = "You have been logged out"
    redirect_to root_path
  end

  private

  def redirect_user
    redirect_to profile_path if current_user.registered?
    redirect_to dashboard_path if current_user.merchant?
    redirect_to root_path if current_user.admin?
  end
end
