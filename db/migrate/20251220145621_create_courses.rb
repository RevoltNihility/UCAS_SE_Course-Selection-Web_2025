class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :credits, null: false
      t.string :teacher

      t.timestamps
    end
  end
end
