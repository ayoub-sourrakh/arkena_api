class HealthController < ActionController::API
  def show
    db_ok = ActiveRecord::Base.connection.select_value("SELECT 1") == 1 rescue false
    render json: {
      status: "ok",
      db: db_ok ? "up" : "down",
      time: Time.now.utc.iso8601
    }
  end
end
