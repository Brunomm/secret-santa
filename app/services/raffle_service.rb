class RaffleService
  def initialize(campaign)
    @campaign = campaign
  end

  def call
    return false if @campaign.members.count < 3
    results = {}
    members = @campaign.members.to_a.shuffle
    set_result!(results, members)
    results
  end

private

  def set_result!( results, members_shuffled )
    last_member  = members_shuffled[-1]
    members_shuffled.map do |m|
      results[m]  = last_member
      last_member = m
    end
  end
end