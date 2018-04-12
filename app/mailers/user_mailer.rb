class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur Prosper')
  end

  def alert(user)
    @user = user
    @properties = Property.last(3)
    mail(to: @user.email, subject: 'Proper / Nouvelles annonces immobilières')
  end
end
