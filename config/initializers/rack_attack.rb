# config/initializers/rack_attack.rb
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.development?

class Rack::Attack
  self.throttled_response = ->(_env) {
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Too many requests' }.to_json]]
  }

  # Laisse passer le healthcheck
  safelist('health') { |req| req.path == '/health' }

  # Sign-in: 10 req / 60s par IP
  throttle('auth/ip', limit: 10, period: 60) do |req|
    req.ip if req.post? && req.path == '/auth/sign_in'
  end

  # Sign-up: 5 req / heure par IP
  throttle('signup/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.post? && req.path == '/auth'
  end
end
