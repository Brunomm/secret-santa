require 'rails_helper'

RSpec.describe CampaignRaffleJob, type: :job do
  let(:campaign) { create(:campaign) }
  let(:member_1) { campaign.members.order(:created_at).first }
  let(:member_2) { create(:member, campaign: campaign) }
  let(:member_3) { create(:member, campaign: campaign) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'the class' do
    it "enqueued a job" do
      expect { CampaignRaffleJob.perform_later(campaign) }.to have_enqueued_job.on_queue("emails")
    end
  end

  context 'when have 3 members or more' do
    before do
      member_2
      member_3
      campaign.reload
    end

    it 'delivers a mail for each member' do
      expect{ CampaignRaffleJob.perform_now(campaign) }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end

    it 'changes campaign status to finished' do
      campaign.update(status: :pending)
      CampaignRaffleJob.perform_now(campaign)
      expect(campaign.status.to_sym).to eq(:finished)
    end

    it 'creates a different token for each member' do
      Member.update_all token: nil
      CampaignRaffleJob.perform_now(campaign)
      member_1.reload
      member_2.reload
      member_3.reload

      expect( member_1.token ).not_to be_nil
      expect( member_1.token ).not_to eq(member_2.token)
      expect( member_2.token ).not_to be_nil
      expect( member_2.token ).not_to eq(member_1.token)
      expect( member_3.token ).not_to be_nil
      expect( member_3.token ).not_to eq(member_1.token)
    end
  end

  context 'when no have 3 members' do
    before do
      member_2
      campaign.reload
    end

    it 'delivers a mail notifying the user of campaign' do
      expect{ CampaignRaffleJob.perform_now(campaign) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'no changes campaign status' do
      campaign.update(status: :pending)
      CampaignRaffleJob.perform_now(campaign)
      expect(campaign.status.to_sym).to eq(:pending)
    end

    it 'no creates token for members' do
      Member.update_all token: nil
      CampaignRaffleJob.perform_now(campaign)
      member_1.reload
      member_2.reload

      expect( member_1.token ).to be_nil
      expect( member_2.token ).to be_nil
    end

  end


  # pending "add some examples to (or delete) #{__FILE__}"
end
