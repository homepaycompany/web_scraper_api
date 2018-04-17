class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur Homepay')
  end

  def alert(user, alerts)
    @user = user
    @alerts_and_properties = {}
    alerts.each do |alert|
      @alerts_and_properties[alert.name] = alert.properties_to_send unless alert.properties_to_send.empty?
    end

    mail(to: @user.email, subject: 'Prosper / Nouvelles annonces immobilières')

    alerts.each do |alert|
      alert.property_alerts_to_send.each do |e|
        e.update(status: 'sent')
      end
    end
  end
end
