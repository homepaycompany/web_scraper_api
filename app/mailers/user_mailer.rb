class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Bienvenue sur Homepay')
  end

  def alert(user_id)
    @user = User.find(user_id)
    alerts = @user.alerts
    unless alerts.empty? || @user.property_alerts_to_send.empty?
      @alerts_and_properties = {}
      alerts.each do |alert|
        @alerts_and_properties[alert] = alert.properties_to_send unless alert.properties_to_send.empty?
      end
      mail(to: @user.email, subject: 'Prosper / Nouvelles annonces immobilières')
      alerts.each do |alert|
        alert.update(last_sent_date: Time.now)
        alert.property_alerts_to_send.each do |e|
          e.update(status: 'sent')
        end
      end
    end
  end
end
