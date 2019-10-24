class User < ApplicationRecord
  # callback: invoked before the user object is saved.
  before_save { self.email = email.downcase }
  
  validates :firstname, presence: true, length: { maximum: 50 };
  validates :lastname, presence: true, length: { maximum: 50 };
  validates :email, presence: true, length: { maximum: 255 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
end