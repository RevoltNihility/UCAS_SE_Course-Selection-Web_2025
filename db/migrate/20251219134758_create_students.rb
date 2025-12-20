class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :name, null: false, limit:20, comment: '学生姓名'
      t.string :email, null: false, comment: '学生邮箱'
      t.string :student_id, null: false, comment: '学号'

      t.timestamps
    end
  end
end
