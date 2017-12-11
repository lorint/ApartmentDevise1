class UserLink < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  belongs_to :link_user, class_name: "User", optional: true

  scope :active, -> { where(active: true) }

  after_initialize do
    if self.new_record?
      self.active = true
    end
  end
end
