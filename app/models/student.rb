class Student < ApplicationRecord
  belongs_to :user
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "Name Format Invalid" }
  validates :student_id, presence: true, uniqueness: true, format: { with: /\A\d{4}K\d{10}\z/, message: "Student_id Format Invalid" }
end
