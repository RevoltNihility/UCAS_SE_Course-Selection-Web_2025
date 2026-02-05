class CreateTeachings < ActiveRecord::Migration[8.1]
  def change
    create_table :teachings do |t|
      t.references :teacher, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :semester

      t.timestamps
    end

    add_index :teachings, [ :teacher_id, :course_id ], unique: true
  end
end
