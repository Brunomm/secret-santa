class NotifyMailer < ApplicationMailer

  def notify_user(campaign)
    @campaign = campaign
    @user = campaign.user
    mail to: @user.email, subject: "Nosso Amigo Secreto: Houve um problema na campanha #{@campaign.title}"
  end
end