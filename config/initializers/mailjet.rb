Mailjet.configure do |config|
  config.api_key = Rails.application.secrets.mailjet[:api_key]
  config.secret_key = Rails.application.secrets.mailjet[:secret_key]
  config.default_from = CONTACT_EMAIL
  puts 'clé mailjet'
  puts "APP_HOST=#{ENV.fetch('APP_HOST')}"

end
