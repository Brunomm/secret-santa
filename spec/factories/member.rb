FactoryBot.define do
  factory :member do
    transient do
      user { build(:user) }
    end

    name         { FFaker::Name.name }
    email        { FFaker::Internet.email }
    campaign     { build(:campaign, user: user) }
  end
end