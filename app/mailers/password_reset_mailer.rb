class PasswordResetMailer < ApplicationMailer
  def reset_email
    @token = params[:token]
    @email = params[:email]
    @url = "#{params[:host]}/reset-password?token=#{@token}&email=#{@email}"  # Frontend handles link

    mail(to: @email, subject: "Password Reset Instructions")
  end
end
