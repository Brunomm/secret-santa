class CampaignRaffleJob < ApplicationJob
  queue_as :emails

  def perform(campaign)
    if results = RaffleService.new(campaign).call
      handle_result( campaign, results )
      campaign.update(status: :finished)
    else
      NotifyMailer.notify_user(campaign).deliver_now
    end
  end

private

    def handle_result campaign, results
      results.each do |member, friend|
        member.set_pixel
        CampaignMailer.raffle(campaign, member, friend).deliver_now
      end
    end

end