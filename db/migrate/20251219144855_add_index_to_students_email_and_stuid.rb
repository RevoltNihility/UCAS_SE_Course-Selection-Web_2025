class AddIndexToStudentsEmailAndStuid < ActiveRecord::Migration[8.1]
  def change
    add_index :students, [ :email, :student_id ], unique: true
  end
end
