# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Language

Always use Chinese(Simplified) instead of English to talk with me!

## Project Overview

This is a **course enrollment management system** built with Ruby on Rails 8.1.1. The application manages course selection for students with role-based access control (student, teacher, admin).

**Technology Stack:**
- Ruby 3.3.10
- Rails 8.1.1
- SQLite3 database
- Hotwire (Turbo + Stimulus) for frontend interactivity
- bcrypt for authentication
- RSpec for testing

## Development Commands

### Setup
```bash
bundle install                    # Install dependencies
bin/rails db:setup               # Create database, load schema, seed data
bin/rails db:migrate             # Run pending migrations
```

### Running the Application
```bash
bin/rails server                 # Start development server (http://localhost:3000)
bin/dev                          # Start with asset watching (if configured)
```

### Testing
```bash
# RSpec (primary test framework)
bundle exec rspec                # Run all RSpec tests
bundle exec rspec spec/models    # Run model tests only
bundle exec rspec spec/path/to/file_spec.rb  # Run specific test file
bundle exec rspec spec/path/to/file_spec.rb:42  # Run specific test at line 42
```

### Linting and Security
```bash
bin/rubocop                      # Check code style
bin/rubocop -a                   # Auto-fix style issues
bin/rubocop -A                   # Auto-fix including unsafe corrections
bin/brakeman --no-pager          # Security vulnerability scan
bin/bundler-audit                # Check for vulnerable gem dependencies
bin/importmap audit              # Check JavaScript dependencies
```

### Database
```bash
bin/rails db:migrate             # Run migrations
bin/rails db:rollback            # Rollback last migration
bin/rails db:seed                # Load seed data
bin/rails db:reset               # Drop, create, migrate, and seed
bin/rails console                # Open Rails console
```

## Architecture

### Core Data Models

The application uses a multi-entity architecture with clear separation of concerns:

```
User (authentication)
  └─ has_one :student (dependent: :destroy)
       └─ has_many :enrollments
            └─ has_many :courses (through: :enrollments)

Course
  └─ has_many :enrollments
       └─ has_many :students (through: :enrollments)
```

**Key Models:**
- `User` - Authentication model with `has_secure_password`, stores email/password
- `Student` - Student profile data (name, email, student_id), belongs to User
- `Course` - Course catalog (name, code, credits, teacher)
- `Enrollment` - Join table connecting Students to Courses (many-to-many)

### Authentication Flow

Session-based authentication using Rails sessions:

1. User logs in via `SessionsController#create`
2. `SessionsHelper#log_in` stores `user_id` in session
3. `SessionsHelper#current_user` retrieves user from session
4. Protected routes use `before_action :request_logged` to enforce authentication
5. After login, users are redirected to `/my_courses/selected_courses`

**Key Files:**
- `app/controllers/sessions_controller.rb` - Login/logout actions
- `app/helpers/sessions_helper.rb` - Session management helpers
- `app/controllers/application_controller.rb` - Base controller with auth helpers

### Controller Organization

Controllers follow Rails conventions with namespacing for feature modules:

- `SessionsController` - Authentication (login/logout)
- `UsersController` - User CRUD operations
- `StudentsController` - Student management
- `MyCourses::SelectedCoursesController` - Student's enrolled courses view

### Testing Strategy

**This project follows Test-Driven Development (TDD) with RSpec:**

**TDD Workflow:**
1. **Red**: Write a failing test first that describes the desired behavior
2. **Green**: Write the minimal code to make the test pass
3. **Refactor**: Improve the code while keeping tests green

**RSpec (Only Testing Framework):**
- Located in `spec/` directory
- Uses FactoryBot for test data generation
- Includes model, controller, view, request, and routing specs
- Run with `bundle exec rspec`

**Test Data:**
- FactoryBot factories in `spec/factories/`
- Faker gem for generating realistic seed data

**Important TDD Principles:**
- Always write tests before implementation code
- Each feature/bug fix should start with a failing test
- Commit tests and implementation separately when appropriate
- Keep tests simple, readable, and focused on one behavior

## Code Style

This project follows **Omakase Rails styling** via `rubocop-rails-omakase`:
- 2-space indentation
- Target Ruby version: 3.3
- Excludes: `db/schema.rb`, `bin/*`

Always run `bin/rubocop` before committing to ensure style compliance.

## Git Workflow

**IMPORTANT: Local-Only Git Operations**

All git operations should be performed locally only. Do NOT perform any operations involving remote repositories:
- ❌ **Never use** `git push`, `git pull`, `git fetch`, or any remote-related commands
- ✅ **Only use** local git commands: `git add`, `git commit`, `git status`, `git diff`, `git log`, etc.
- If you see git messages about being "ahead of origin" or other remote repository warnings, **ignore them** or ask the user for guidance
- The user will handle all remote repository synchronization manually

This is a strict requirement to prevent unintended changes to shared repositories.

## Important Patterns

### Model Relationships
When creating or modifying models, maintain the established relationship pattern:
- Use `dependent: :destroy` for owned associations (e.g., User → Student)
- Use `through:` associations for many-to-many relationships
- Keep join tables simple (Enrollment model)

### Authentication Guards
Protected routes should include authentication checks:
```ruby
before_action :request_logged  # Defined in ApplicationController
```

### Route Organization
Routes use namespacing for feature modules:
```ruby
namespace :my_courses do
  resources :selected_courses, only: [:index]
end
```

## CI/CD Pipeline

GitHub Actions runs on PRs and pushes to main:
- **Security Scans**: Brakeman (Rails), bundler-audit (gems), importmap audit (JS)
- **Linting**: RuboCop with Omakase style
- **Tests**: Minitest suite + system tests
- Failed system tests save screenshots to artifacts

## Deployment

- Docker support via Dockerfile
- Kamal for container deployment
- Thruster for HTTP caching/compression
- Solid Cache/Queue/Cable for production infrastructure
