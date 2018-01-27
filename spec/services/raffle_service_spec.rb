require 'rails_helper'

describe RaffleService do
  let(:campaign) { build(:campaign, status: :pending) }
  let(:results) { RaffleService.new(campaign).call }

  describe '#call' do
    context "when has more then two members" do

      before(:each) do
        4.times.map{ |i|  campaign.members.build(attributes_for(:member)) }
        allow(campaign.members).to receive(:count) { 3 } # Stubs campaign.members count
      end

      it "results is a hash" do
        expect(results.class).to eq(Hash)
      end

      it "all members are in results as a member" do
        result_members = results.map {|r| r.first}
        expect(result_members).to match_array(campaign.members.to_a)
      end

      it "all member are in results as a friend" do
        result_friends = results.map {|r| r.last}
        expect(result_friends).to match_array(campaign.members.to_a)
      end

      it "a member don't get yourself" do
        results.each do |r|
          expect(r.first).not_to eq(r.last)
        end
      end

      # Desafio - Challenge accepted 8-]
      it 'a member x dont get a member y that get the member x' do
        result_members = results.map {|r| r.first}
        result_members.each do |member|
          friend = results[member]
          expect(results[friend]).not_to eq(member)
        end
      end

    end

    context "when don't has more then two members" do
      before(:each) do
        allow(campaign.members).to receive(:count) { 2 } # Stubs campaign.members count
      end

      it "raise error" do
        expect(results).to eql(false)
      end
    end
  end
end