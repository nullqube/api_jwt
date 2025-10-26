Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"  # Adjust for Ionic
    resource "*",
        headers: :any,
        expose: [ "Authorization", "X-Refresh-Token", "X-Device-Id", "X-Device-Name" ],
        methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
        credentials: false
  end
end
