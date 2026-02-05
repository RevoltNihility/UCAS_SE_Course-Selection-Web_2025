class ChangeCreditsToDecimalInCourses < ActiveRecord::Migration[8.1]
  def change
    change_column :courses, :credits, :decimal, precision: 4, scale: 1, null: false
  end
end
