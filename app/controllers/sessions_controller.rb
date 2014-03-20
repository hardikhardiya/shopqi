class SessionsController < ApplicationController
	def create
    user = User.from_omniauth(env["omniauth.auth"])
    debugger
    session[:uid]      = env["omniauth.auth"][:uid]
    session[:provider] = env["omniauth.auth"][:provider]
    session[:email]    = env["omniauth.auth"]["info"]["email"] 
    session[:name]     = env["omniauth.auth"]["info"]["name"]
    #session[:oauth_token]=env["omniauth.auth"][:oauth_token]
    #session[:oauth_expires_at]=env["omniauth.auth"][:oauth_expires_at]
    session[:user_id] = user.id
    redirect_to services_signup_path
  end
  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end

