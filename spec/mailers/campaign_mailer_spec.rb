require "rails_helper"

RSpec.describe CampaignMailer, type: :mailer do
  let(:campaign) { create(:campaign) }
  let(:member)   { create(:member, campaign: campaign) }
  let(:friend)   { create(:member, campaign: campaign) }
  describe "raffle" do
    let!(:mail) { CampaignMailer.raffle(campaign, member, friend) }

    it "renders the headers" do
      expect(mail.subject).to eq("Nosso Amigo Secreto: #{campaign.title}")
      expect(mail.to).to eq([member.email])
    end

    it "body have member name" do
      expect(mail.body.encoded).to match(member.name)
    end

    it "body have campaign creator name" do
      expect(mail.body.encoded).to match(campaign.user.name)
    end

    it "body have member link to set open" do
      expect(mail.body.encoded).to match("/members/#{member.token}/opened")
    end
  end

end