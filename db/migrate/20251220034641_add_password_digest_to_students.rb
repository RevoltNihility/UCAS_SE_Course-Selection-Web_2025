class AddPasswordDigestToStudents < ActiveRecord::Migration[8.1]
  def change
    add_column :students, :password_digest, :string
  end
end
