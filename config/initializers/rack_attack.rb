# class Rack::Attack
#   throttle("req/ip", limit: 5, period: 1.minute) do |req|
#     req.ip if req.path =~ %r{^/api/v1/auth/login} && req.post?
#   end

#   throttle("req/ip", limit: 3, period: 5.minutes) do |req|
#     req.ip if req.path =~ %r{^/api/v1/auth/signup} && req.post?
#   end
# end

# class Rack::Attack
#   # Allow requests from localhost in development
#   safelist("allow-localhost") do |req|
#     req.ip == "127.0.0.1" || req.ip == "::1" if Rails.env.development?
#   end

#   # Throttle login attempts per IP
#   throttle("auth/login/ip", limit: 5, period: 1.minute) do |req|
#     if req.path == "/api/v1/auth/login" && req.post?
#       req.ip
#     end
#   end

#   # Throttle signup attempts per IP
#   throttle("auth/signup/ip", limit: 3, period: 5.minutes) do |req|
#     if req.path == "/api/v1/auth/signup" && req.post?
#       req.ip
#     end
#   end

#   # Throttle refresh token requests
#   throttle("auth/refresh/ip", limit: 10, period: 1.minute) do |req|
#     if req.path == "/api/v1/auth/refresh" && req.post?
#       req.ip
#     end
#   end

#   # Block suspicious requests
#   blocklist("fail2ban") do |req|
#     # Block IPs that make too many failed login attempts
#     Rack::Attack::Fail2Ban.filter("fail2ban-#{req.ip}", maxretry: 10, findtime: 10.minutes, bantime: 1.hour) do
#       req.path == "/api/v1/auth/login" && req.post? && req.env["rack.attack.match_type"] == :throttle
#     end
#   end

#   # Custom throttled response
#   self.throttled_response = lambda do |env|
#     retry_after = env["rack.attack.match_data"][:period]
#     [
#       429,
#       {
#         "Content-Type" => "application/json",
#         "Retry-After" => retry_after.to_s
#       },
#       [ { error: "Too many requests. Please try again later.", retry_after: retry_after }.to_json ]
#     ]
#   end

#   # Custom blocked response
#   self.blocklisted_response = lambda do |env|
#     [
#       403,
#       { "Content-Type" => "application/json" },
#       [ { error: "Your IP has been blocked due to suspicious activity." }.to_json ]
#     ]
#   end
# end
