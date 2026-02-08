class ApplicationController < ActionController::API
  # Global error handlers
  rescue_from ActionController::ParameterMissing do |exception|
    render json: {
      error: 'Missing required parameter',
      message: exception.message
    }, status: :bad_request
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {
      error: 'Record not found',
      message: exception.message
    }, status: :not_found
  end
  
  rescue_from ActiveRecord::CheckViolation do |exception|
    # Extract constraint name from error message
    constraint_name = exception.message.match(/constraint "([^"]+)"/)[1] rescue 'unknown'
    
    error_message = case constraint_name
    when 'valid_india_mobile_phone'
      'Phone must be a valid Indian mobile number (10 digits starting with 6-9, optionally prefixed with +91 or 91)'
    else
      'Database constraint violation'
    end
    
    render json: {
      error: 'Validation failed',
      message: error_message
    }, status: :unprocessable_entity
  end
end
