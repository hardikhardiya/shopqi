#encoding: utf-8
class Shopqi::RegistrationsController < Devise::RegistrationsController
  include Shopqi::HomeHelper
  skip_before_filter :force_domain # Do not need to redirect
  before_filter :clear_current_user_for_observer
  layout 'shopqi'

  expose(:themes_json) do
    Theme.all.take(7) do |result, theme|
      result << { theme: theme.attributes }; result
    end.to_json
  end

  expose(:signup_source_options) { KeyValues::Shop::SignupSource.options }

  def new
    params[:plan] ||= :professional
    (render action: :forbid and return) unless Setting.can_register
  end

  def create
    data = {errors: {}}
    # if is_code_valid? # Mobile checksum (the test environment does not verify)
    #   session[:verify_code] = nil
      build_resource
      resource.shop.themes.first.theme_id ||= Theme.default.id
      resource.shop.email = resource.email #Default mailbox store when registered user mailboxes
      unless session[:uid].nil? && session[:provider].nil? && session[:oauth_token].nil? && session[:oauth_expires_at].nil
        resource.uid = session[:uid]
        resource.provider = session[:provider]
        resource.oauth_token = session[:oauth_token]
        resource.oauth_expires_at = session[:oauth_expires_at]
      end
      if resource.save
        Rails.cache.write(registered_cache_key, true, expires_in: 24.hours) # Avoid duplication of registration
        data[:token] = resource.authentication_token
        flash[:notice] = "shop is created sucessfully"
      else
        data[:errors] = resource.errors
      end
    # else
    #   data[:errors] = {verify_code: 'Mobile checksum is incorrect'}
    # end
    render json: data.to_json
  end

  def check_availability
    render text: ShopDomain.exists?(host: "#{params[:domain]}")
  end

  # def verify_code
  #   receiver = params[:phone]
  #   session[:verify_code] ||= Random.new.rand(1000..9999)
  #   content = "Hello! Verification code to your mobile phone:#{session[:verify_code]}"
  #   if development?
  #     puts content # Directly to the verification code displayed in the background when developing
  #   else
  #     SMS.safe_send receiver, content, request.remote_ip
  #   end
  #   render nothing: true
  # end

  private
  def is_code_valid? # Test environment, or have not yet registered, you do not need to check code
    Rails.env.test? or !is_registered? or params[:verify_code].to_i == session[:verify_code]
  end

  def clear_current_user_for_observer # Current_user class variables may remain after the thread finished processing other stores user actions
    ActivityObserver.current_user = nil
  end
end
