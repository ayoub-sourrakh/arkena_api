# frozen_string_literal: true

Devise.setup do |config|
  # ==> Mailer Configuration
  config.mailer_sender = "please-change-me@example.com"

  # ==> ORM configuration
  require "devise/orm/active_record"

  # ==> Controller config for API-only
  config.parent_controller = "ApplicationController"
  config.navigational_formats = [] # pas de HTML, seulement JSON
  config.skip_session_storage = [ :http_auth, :params_auth ] # pas de sessions

  # ==> JWT configuration
  config.jwt do |jwt|
    jwt.secret = ENV["DEVISE_JWT_SECRET_KEY"]

    # Quand un token est généré (login)
    jwt.dispatch_requests = [
      [ "POST", %r{^/auth/sign_in$} ]
    ]

    # Quand un token est révoqué (logout)
    jwt.revocation_requests = [
      [ "DELETE", %r{^/auth/sign_out$} ]
    ]

    jwt.expiration_time = 30.minutes.to_i
  end

  # ==> Password configuration
  config.stretches = Rails.env.test? ? 1 : 12
  config.pepper = "some-random-string-change-this"

  # ==> Misc
  config.reconfirmable = false
  config.password_length = 6..128
  config.reset_password_within = 6.hours
end
