class Task < ApplicationRecord
  include QueueIt::Queable
end
