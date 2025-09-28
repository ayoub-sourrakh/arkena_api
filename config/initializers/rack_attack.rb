Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.development?

class Rack::Attack
  self.throttled_responder = lambda do |request|
    match = request.env["rack.attack.match_data"] || {}
    retry_after = match[:period].to_i if match[:period]
    headers = { "Content-Type" => "application/json" }
    headers["Retry-After"] = retry_after.to_s if retry_after
    [ 429, headers, [ { error: "Too many requests" }.to_json ] ]
  end

  safelist("health") { |req| req.path == "/health" }

  # courte: 6 / 10s
  throttle("auth/ip:10s", limit: 6, period: 10) do |req|
    req.ip if req.post? && req.path == "/auth/sign_in"
  end

  # longue: 20 / 60s (ajuste selon ton besoin)
  throttle("auth/ip:1m", limit: 20, period: 60) do |req|
    req.ip if req.post? && req.path == "/auth/sign_in"
  end
end
