class UpdateCourseTypeEnumInCourses < ActiveRecord::Migration[8.1]
  def up
    # 添加临时列
    add_column :courses, :course_type_new, :integer, default: 2, null: false

    # 映射旧值到新值
    # 旧: required (0) -> 新: major_required (2)
    # 旧: elective (1) -> 新: major_elective (3)
    # 旧: public_elective (2) -> 新: public_elective (1)
    execute <<-SQL
      UPDATE courses
      SET course_type_new = CASE course_type
        WHEN 0 THEN 2  -- required -> major_required
        WHEN 1 THEN 3  -- elective -> major_elective
        WHEN 2 THEN 1  -- public_elective -> public_elective
        ELSE 2         -- 默认为 major_required
      END
    SQL

    # 删除旧列
    remove_column :courses, :course_type

    # 重命名新列
    rename_column :courses, :course_type_new, :course_type
  end

  def down
    # 添加临时列
    add_column :courses, :course_type_old, :integer, default: 0, null: false

    # 反向映射
    # 新: public_required (0) -> 旧: required (0)
    # 新: public_elective (1) -> 旧: public_elective (2)
    # 新: major_required (2) -> 旧: required (0)
    # 新: major_elective (3) -> 旧: elective (1)
    execute <<-SQL
      UPDATE courses
      SET course_type_old = CASE course_type
        WHEN 0 THEN 0  -- public_required -> required
        WHEN 1 THEN 2  -- public_elective -> public_elective
        WHEN 2 THEN 0  -- major_required -> required
        WHEN 3 THEN 1  -- major_elective -> elective
        ELSE 0         -- 默认为 required
      END
    SQL

    # 删除新列
    remove_column :courses, :course_type

    # 重命名旧列
    rename_column :courses, :course_type_old, :course_type
  end
end
