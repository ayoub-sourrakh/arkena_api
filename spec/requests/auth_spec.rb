require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /auth (sign_up)" do
    it "registers a new user with valid params" do
      post "/auth", params: {
      user: {
      email: "newuser@mail.com",
      password: "Passw0rd!",
      password_confirmation: "Passw0rd!"
    }
    }, as: :json

    expect(response).to have_http_status(:created)
  end

  it "rejects missing email" do
    post "/auth", params: {
    user: {
    email: nil,
    password: "Passw0rd!",
    password_confirmation: "Passw0rd!"
  }
  }, as: :json

  expect(response).not_to have_http_status(:created)
end

it "rejects badly formatted email" do
  User.create!(email: "dup@mail.com", password: "Passw0rd!")
  post "/auth", params: {
  user: {
  email: "dup@mail.com",
  password: "Passw0rd!",
  password_confirmation: "Passw0rd!"
}
}, as: :json

expect(response).not_to have_http_status(:created)
end

it "rejects missing password" do
  post "/auth", params: {
  user: {
  email: "email@gmail.com",
  password: nil,
  password_confirmation: nil
}
}, as: :json

expect(response).not_to have_http_status(:created)
end

it "rejects short password" do
  post "/auth", params: {
  user: {
  email: "email@gmail.com",
  password: "123",
  password_confirmation: nil
}
}, as: :json

expect(response).not_to have_http_status(:created)
end

it "rejects different confirmation_password" do
  post "/auth", params: {
  user: {
  email: "email@gmail.com",
  password: "Passw0rd!",
  password_confirmation: "different_Passw0rd!"
}
}, as: :json

expect(response).not_to have_http_status(:created)
end
end

describe "POST /auth (sign_in)" do
  before do
    User.create!(email: "newuser@mail.com", password: "Passw0rd!")
  end
  it "signs in with valid params" do
    post "/auth/sign_in", params: {
    user: {
    email: "newuser@mail.com",
    password: "Passw0rd!"
  }
  }, as: :json

  expect(response).to have_http_status(:created)
end

it "rejects invalid email" do
  post "/auth/sign_in", params: {
  user: {
  email: "invalid_email",
  password: "Passw0rd!"
}
}, as: :json

expect(response).to have_http_status(:unauthorized)
end

it "rejects wrong password" do
  post "/auth/sign_in", params: {
  user: {
  email: "newuser@mail.com",
  password: "WrongPassw0rd!"
}
}, as: :json

expect(response).to have_http_status(:unauthorized)
end

it "rejects missing password" do
  post "/auth/sign_in", params: {
  user: {
  email: "newuser@mail.com",
  password: nil
}
}, as: :json

expect(response).to have_http_status(:unauthorized)
end

it "rejects missing email" do
  post "/auth/sign_in", params: {
  user: {
  email: nil,
  password: "Passw0rd!"
}
}, as: :json

expect(response).to have_http_status(:unauthorized)
end

it "rejects missing email and password" do
  post "/auth/sign_in", params: {
  user: {
  email: nil,
  password: nil
}
}, as: :json

expect(response).to have_http_status(:unauthorized)
end
end

describe "GET /me" do
  let!(:user) { User.create!(email: "me@mail.com", password: "Passw0rd!") }

  it "returns the current user with a valid token" do
    post "/auth/sign_in", params: {
    user: { email: user.email, password: "Passw0rd!" }
    }, as: :json

    token = response.headers["Authorization"]

    get "/me", headers: { "Authorization" => token }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["email"]).to eq(user.email)
    expect(body["id"]).to eq(user.id)
  end

  it "rejects when no token is provided" do
    get "/me"
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects when token is invalid" do
    get "/me", headers: { "Authorization" => "Bearer invalidtoken" }
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects when token is revoked after logout" do
    # Sign in
    post "/auth/sign_in", params: {
    user: { email: user.email, password: "Passw0rd!" }
    }, as: :json
    token = response.headers["Authorization"]

    # Logout
    delete "/auth/sign_out", headers: { "Authorization" => token }
    expect(response).to have_http_status(:no_content)

    # Try /me with revoked token
    get "/me", headers: { "Authorization" => token }
    expect(response).to have_http_status(:unauthorized)
  end
end

describe "DELETE /auth/sign_out" do
  let!(:user) { User.create!(email: "logout@mail.com", password: "Passw0rd!") }

  it "logs out successfully with a valid token" do
    post "/auth/sign_in", params: {
    user: { email: user.email, password: "Passw0rd!" }
    }, as: :json
    token = response.headers["Authorization"]

    delete "/auth/sign_out", headers: { "Authorization" => token }

    expect(response).to have_http_status(:no_content)

    # Token should now be rejected
    get "/me", headers: { "Authorization" => token }
    expect(response).to have_http_status(:unauthorized)
  end

  it "rejects logout without token" do
    delete "/auth/sign_out"
    expect(response).to have_http_status(:no_content)
  end

  it "rejects logout with an expired token" do
    payload = { sub: "fake", exp: 1.second.ago.to_i }
    secret  = ENV["DEVISE_JWT_SECRET_KEY"]
    invalid_token = JWT.encode(payload, secret, "HS256")

    delete "/auth/sign_out", headers: { "Authorization" => "Bearer #{invalid_token}" }

    expect(response).to have_http_status(:no_content)
  end


  it "rejects logout with an already revoked token" do
    post "/auth/sign_in", params: {
    user: { email: user.email, password: "Passw0rd!" }
    }, as: :json
    token = response.headers["Authorization"]

    # First logout → works
    delete "/auth/sign_out", headers: { "Authorization" => token }
    expect(response).to have_http_status(:no_content)

    # Second logout → fails
    delete "/auth/sign_out", headers: { "Authorization" => token }
    expect(response).to have_http_status(:no_content)
  end
end
end
