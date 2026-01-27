class User < ApplicationRecord
  has_one :student, dependent: :destroy

  enum :role, { student: 0, teacher: 1, admin: 2 }

  has_secure_password
end
