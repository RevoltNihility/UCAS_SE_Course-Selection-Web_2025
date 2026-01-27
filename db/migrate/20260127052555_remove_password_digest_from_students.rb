class RemovePasswordDigestFromStudents < ActiveRecord::Migration[8.1]
  def change
    remove_column :students, :password_digest, :string
  end
end
