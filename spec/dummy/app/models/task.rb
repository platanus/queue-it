class Task < ApplicationRecord
  include QueueIt::Concerns::Queable
end
