class HealthController < ActionController::API
  # GET /health
  def index
    render json: {
      status: 'ok',
      message: 'Server is up and running',
      timestamp: Time.current.iso8601,
      environment: Rails.env,
      version: '1.0.0'
    }, status: :ok
  end
end
