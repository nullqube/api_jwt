# lib/tasks/dev.rake
# Rake tasks for setting up and managing the development environment.
# Includes tasks for creating test users and generating test tokens.
# Usage:
#  rake dev:setup
#  rake dev:test_tokens[email]
#  Replace 'email' with the desired user's email or omit to use the default test user.

namespace :dev do
  desc "Setup development environment"
  task setup: :environment do
    puts "🚀 Setting up development environment..."

    # Create test user
    user = User.find_or_create_by(email: "test@example.com") do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
    end

    puts "✓ Created test user: #{user.email}"
    puts "  Password: password123"
    puts "\n🎉 Development setup complete!"
  end

  desc "Generate test tokens"
  task :test_tokens, [ :email ] => :environment do |t, args|
    user = User.find_by(email: args[:email] || "test@example.com")

    if user
      access_token = JwtService.encode_access_token(user.id)
      refresh_token = user.refresh_tokens.create!(
        device_id: "test-device",
        device_name: "Test Device"
      )

      puts "\n📝 Test Tokens Generated"
      puts "=" * 60
      puts "Access Token:"
      puts access_token
      puts "\nRefresh Token:"
      puts refresh_token.token
      puts "=" * 60
    else
      puts "❌ User not found: #{args[:email]}"
    end
  end
end
