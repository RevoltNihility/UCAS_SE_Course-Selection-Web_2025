class CreateTeachers < ActiveRecord::Migration[8.1]
  def change
    create_table :teachers do |t|
      t.string :name, limit: 50, null: false
      t.string :email, null: false
      t.string :teacher_id, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :teachers, :email, unique: true
    add_index :teachers, :teacher_id, unique: true
  end
end
