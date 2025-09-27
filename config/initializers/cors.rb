Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # dev uniquement
    resource '*',
      headers: :any,
      expose:  ['Authorization'],
      methods: %i[get post put patch delete options head]
  end
end