class AddClassHoursToCourses < ActiveRecord::Migration[8.1]
  def change
    add_column :courses, :class_hours, :integer
  end
end
