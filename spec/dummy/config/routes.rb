Rails.application.routes.draw do
  mount QueueIt::Engine => "/queue_it"
end
