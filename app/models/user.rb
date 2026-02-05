class User < ApplicationRecord
  has_one :student, dependent: :destroy
  has_one :teacher, dependent: :destroy

  enum :role, { student: 0, teacher: 1, admin: 2 }

  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, length: { minimum: 6 }, allow_nil: true

  has_secure_password
end
