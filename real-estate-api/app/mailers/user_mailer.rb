class UserMailer < ApplicationMailer
  default from: 'noreply@realestate-api.com'

  # Send invitation email to new user
  def invitation_email(user)
    @user = user
    @invitation_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:5173')}/accept-invitation?token=#{user.invitation_token}"
    
    mail(
      to: user.email,
      subject: 'You have been invited to join Real Estate CRM'
    )
  end
end
