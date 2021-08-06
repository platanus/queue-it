FactoryBot.define do
  factory :queue, class: 'QueueIt::Queue' do
    queable { create(:task) }
  end
end
