OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1454815641415434', '56f1437901bfc5357c308b57b2207622',
           :scope => 'email,user_birthday,read_stream,publish_actions,read_friendlists,offline_access,publish_stream'
end