class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher
end
