# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    user = User.first
    UserMailer.welcome(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/alert
  def alert
    user = User.first
    UserMailer.alert(user)
  end
end
