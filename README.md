# 选课管理系统

基于 Ruby on Rails 8.1.1 开发的课程选课管理系统,支持学生选课、教师查看授课信息等功能。

## ✨ 核心功能

### 学生功能
- 📚 **课程浏览与筛选** - 按课程名称、类型、上课时间筛选课程
- ✅ **在线选课** - 自动检测课程满员、时间冲突、重复选课
- 📋 **已选课程管理** - 查看、筛选、退课
- 📅 **课程表可视化** - 直观展示每周课程安排
- 📊 **学分统计** - 按课程类型统计已修学分

### 教师功能
- 👨‍🏫 **授课课程管理** - 查看所授课程列表
- 👥 **学生名单查看** - 查看每门课程的选课学生信息

### 系统特性
- 🔐 基于 Session 的用户认证
- 🚫 课程容量控制(防止超额选课)
- ⚠️ 上课时间冲突检测
- 📆 学年学期管理
- 🏷️ 课程类型分类(公共必修/选修、专业必修/选修)

## 🛠️ 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Ruby | 3.3.10 | 编程语言 |
| Rails | 8.1.1 | Web 框架 |
| SQLite3 | - | 数据库 |
| Hotwire | - | 前端交互(Turbo + Stimulus) |
| RSpec | - | 测试框架 |
| bcrypt | - | 密码加密 |

## 📋 环境要求

- Ruby 3.3.10 或更高版本
- Bundler 2.x
- SQLite3
- Git

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/RevoltNihility/UCAS_SE_Course-Selection-Web_2025.git
cd course-selection
```

### 2. 安装依赖

```bash
bundle install
```

### 3. 数据库初始化

```bash
# 创建数据库、运行迁移、加载种子数据
bin/rails db:setup
```

这将创建:
- 100 个学生账号(1 个主测试账号 + 99 个随机账号)
- 约 40 门课程(涵盖各类课程类型)
- 16 位教师账号
- 部分满员课程的选课记录

### 4. 启动服务器

```bash
bin/rails server
```

访问 `http://localhost:3000` 即可使用系统。

## 👤 测试账号

### 学生账号(推荐)

| 邮箱 | 密码 | 学号 | 姓名 |
|------|------|------|------|
| `qiuzitao23@mails.ac.cn` | `correct_password` | 2023K8000000000 | Zitao Qiu |

### 教师账号

| 邮箱 | 密码 | 说明 |
|------|------|------|
| `teacher1@university.edu.cn` | `teacher123` | 教师测试账号 |
| `teacher2@university.edu.cn` | `teacher123` | 教师测试账号 |

更多测试账号请查看 [完整文档](doc/README.md#5-可用的测试用户)。

## 🧪 开发命令

### 测试

```bash
# 运行所有测试
bundle exec rspec

# 运行特定测试文件
bundle exec rspec spec/models/user_spec.rb

# 运行特定测试行
bundle exec rspec spec/models/user_spec.rb:42
```

### 代码质量检查

```bash
# 代码风格检查
bin/rubocop

# 自动修复风格问题
bin/rubocop -a

# 安全漏洞扫描
bin/brakeman --no-pager

# Gem 依赖安全检查
bin/bundler-audit
```

### 数据库操作

```bash
# 运行迁移
bin/rails db:migrate

# 回滚最后一次迁移
bin/rails db:rollback

# 重置数据库(清空并重新加载)
bin/rails db:reset

# 打开 Rails 控制台
bin/rails console
```

## 📁 项目架构

### 核心数据模型

```
User (用户认证)
├── has_one :student (学生信息)
│   └── has_many :enrollments (选课记录)
│       └── has_many :courses (through: :enrollments)
└── has_one :teacher (教师信息)
    └── has_many :courses (授课课程)

Course (课程)
├── has_many :enrollments
│   └── has_many :students (through: :enrollments)
└── belongs_to :teacher
```

### 认证流程

- 基于 Rails Session 的认证机制
- `SessionsController` 处理登录/登出
- `SessionsHelper` 提供会话管理辅助方法
- `ApplicationController` 提供认证守卫

### 控制器组织

- `SessionsController` - 用户认证
- `MyCourses::*` - 学生功能模块(选课、课程表、学分统计)
- `TeacherCourses::*` - 教师功能模块(授课管理、学生名单)

## 🧑‍💻 开发规范

### TDD 工作流

本项目遵循测试驱动开发(TDD):

1. **Red** - 先编写失败的测试
2. **Green** - 编写最小代码使测试通过
3. **Refactor** - 重构代码保持测试通过

### 代码风格

遵循 **Omakase Rails** 风格规范:
- 2 空格缩进
- 目标 Ruby 版本: 3.3
- 提交前运行 `bin/rubocop` 确保风格一致

### Git 工作流

⚠️ **重要**: 本项目仅使用本地 Git 操作
- ✅ 允许: `git add`, `git commit`, `git status`, `git diff`, `git log`
- ❌ 禁止: `git push`, `git pull`, `git fetch` 等远程操作
- 用户将手动处理远程仓库同步

## 📚 文档

- [完整使用文档](doc/README.md) - 详细的功能使用指南
- [需求设计文档](doc/requirements.md) - 系统需求与设计说明

## 🤝 贡献

欢迎提交 Issue 和 Pull Request!

## 📄 许可证

本项目仅用于学习和教学目的。

---

**开发团队**: UCAS 软件工程课程项目组
**开发时间**: 2025
