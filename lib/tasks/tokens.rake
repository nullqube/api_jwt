# Documented inn /docs/tokens.md
# rake tasks for managing refresh tokens
# Usage:
#  rake tokens:cleanup          # Clean up expired tokens
#  rake tokens:stats            # Show token statistics
#  rake tokens:revoke_user[user@example.com]  # Revoke all tokens for a user by email
#
namespace :tokens do
  desc "Clean up expired refresh tokens"
  task cleanup: :environment do
    count = RefreshToken.cleanup_expired!
    puts "Cleaned up #{count} expired refresh tokens"
  end

  desc "Show token statistics"
  task stats: :environment do
    total = RefreshToken.count
    active = RefreshToken.active.count
    expired = RefreshToken.expired.count
    revoked = RefreshToken.where(revoked: true).count

    puts "\n📊 Token Statistics"
    puts "=" * 50
    puts "Total tokens:    #{total}"
    puts "Active tokens:   #{active}"
    puts "Expired tokens:  #{expired}"
    puts "Revoked tokens:  #{revoked}"
    puts "=" * 50
  end

  desc "Revoke all tokens for a user by email"
  task :revoke_user, [ :email ] => :environment do |t, args|
    unless args[:email]
      puts "Usage: rake tokens:revoke_user[user@example.com]"
      exit
    end

    user = User.find_by(email: args[:email])

    if user
      user.revoke_all_tokens!
      puts "✓ All tokens revoked for #{user.email}"
    else
      puts "✗ User not found: #{args[:email]}"
    end
  end
end
