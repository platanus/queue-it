FactoryBot.define do
  factory :queue, class: 'QueueIt::Queue' do
    queable { create(:task) }

    trait :with_one_node do
      after(:create) do |queue|
        create(:node, :head, queue: queue)
      end
    end

    trait :with_two_nodes do
      after(:create) do |queue|
        head_node = create(:node, :head, queue: queue)
        create(:node, :tail, queue: queue, parent_node: head_node)
      end
    end

    trait :with_three_nodes do
      after(:create) do |queue|
        head_node = create(:node, :head, queue: queue)
        any_node = create(:node, :any, queue: queue, parent_node: head_node)
        create(:node, :tail, queue: queue, parent_node: any_node)
      end
    end
  end
end
