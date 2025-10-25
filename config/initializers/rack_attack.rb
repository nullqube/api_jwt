# class Rack::Attack
#   throttle("req/ip", limit: 5, period: 1.minute) do |req|
#     req.ip if req.path =~ %r{^/api/v1/auth/login} && req.post?
#   end

#   throttle("req/ip", limit: 3, period: 5.minutes) do |req|
#     req.ip if req.path =~ %r{^/api/v1/auth/signup} && req.post?
#   end
# end
