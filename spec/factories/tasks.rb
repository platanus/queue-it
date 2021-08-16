FactoryBot.define do
  factory :task do
    name { "My Task" }

    trait :with_three_nodes do
      after(:create) do |task|
        create(:queue, :with_three_nodes, queable: task)
      end
    end
  end
end
