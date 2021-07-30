FactoryBot.define do
  factory :node, class: 'QueueIt::Node' do
    nodable { create(:user) }
    queue

    trait :head do
      kind { :head }
    end

    trait :any do
      kind { :any }
    end

    trait :tail do
      kind { :tail }
    end
  end
end
