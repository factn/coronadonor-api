class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :requested, class_name: "Scenario", dependent: :nullify, inverse_of: :requester, foreign_key: :requester_id
  has_many :done, class_name: "Scenario", dependent: :nullify, inverse_of: :doer, foreign_key: :doer_id

  has_many :donated, class_name: "Donation", dependent: :nullify, inverse_of: :donator, foreign_key: :donator_id
  has_many :verified, class_name: "Proof", dependent: :nullify, inverse_of: :verifier, foreign_key: :verifier_id

  has_many :user_ad_interactions, dependent: :nullify

  has_attached_file :avatar, styles: {
    thumb: "100x100>",
    square: "200x200#",
    medium: "300x300>"
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, content_type: %r{\Aimage\/.*\Z}

  def name
    firstname + " " + lastname
  end

  def firstname
    firstname.slice(0,1).capitalize + firstname.slice(1..-1) if firstname
  end
end
