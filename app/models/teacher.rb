class Teacher < ApplicationRecord
  belongs_to :user
  has_many :teachings, dependent: :destroy
  has_many :courses, through: :teachings

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :teacher_id, presence: true, uniqueness: true, format: { with: /\AT\d{8}\z/ }
end
