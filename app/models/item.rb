class Item < ApplicationRecord
  has_paper_trail on: [:create, :update], save_changes: true
end
