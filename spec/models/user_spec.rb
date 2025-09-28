require "rails_helper"

RSpec.describe User, type: :model do
  it "is invalid without email" do
    user = User.new(email: nil, password: "Passw0rd!")
    expect(user).not_to be_valid
  end

  it "is invalid if email is not unique" do
    User.create!(email: "dup@mail.com", password: "Passw0rd!")
    user = User.new(email: "dup@mail.com", password: "Passw0rd!")
    expect(user).not_to be_valid
  end

  it "is invalid with a badly formatted email" do
    user = User.new(email: "invalid_email", password: "Passw0rd!")
    expect(user).not_to be_valid
  end

  it "is invalid without a password" do
    user = User.new(email: "email@email.com", password: nil)
    expect(user).not_to be_valid
  end

  it "is invalid with a short password" do
    user = User.new(email: "email@email.com", password: "123")
    expect(user).not_to be_valid
  end

  it "is invalid with a password confirmation different than the password" do
    user = User.new(email: "email@email.com", password: "Passw0rd!", password_confirmation: "Different1!")
    expect(user).not_to be_valid
  end
end
