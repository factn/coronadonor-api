class Scenario < ApplicationRecord
  after_save do |ob|
    mqtt_me(ob)
  end

  belongs_to :verb
  belongs_to :noun
  belongs_to :event
  belongs_to :requester, class_name: "User", inverse_of: :requested, optional: true
  belongs_to :doer, class_name: "User", inverse_of: :done, optional: true
  belongs_to :parent_scenario, class_name: "Scenario", inverse_of: :children_scenario, optional: true

  # has_many :verifications, class_name: 'Vouches', dependent: :destroy, inverse_of: :scenario
  has_many :vouches, dependent: :destroy
  has_many :donations, dependent: :destroy
  has_many :children_scenario, class_name: "Scenario", dependent: :nullify, inverse_of: :parent_scenario, foreign_key: :parent_scenario_id
  has_many :user_ad_interactions, dependent: :destroy

  delegate :firstname, :lastname, :latitude, :longitude, to: :doer, prefix: true, allow_nil: true
  delegate :firstname, :lastname, :latitude, :longitude, to: :requester, prefix: true, allow_nil: true

  # has_many :ads

  has_attached_file :image, styles: {
    thumb: "100x100>",
    square: "200x200#",
    medium: "300x300>"
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :image, content_type: %r{\Aimage\/.*\Z}

  scope :examples_for_demo, -> { where("id in (1)") }

  def self.create_subtask(new_scenario, goal)
    Scenario.create(parent_scenario: new_scenario,
                    event: new_scenario.event,
                    requester: new_scenario.requester,
                    verb: Verb.find_or_create_by(description: goal[:verb]),
                    noun: Noun.find_or_create_by(description: goal[:noun]),
                    custom_message: goal[:custom_message])
  end

  def description
    verb.description + " " + noun.description + (requester ? " for " + requester.name : "") + " in " + event.description
  end

  def parent_description
    return if parent_scenario.nil?

    parent_scenario.description
  end

  def requesterlat
    requester&.latitude
  end

  def requesterlon
    requester&.longitude
  end

  def doerlat
    doer&.latitude
  end

  def doerlon
    doer&.longitude
  end

  def donated
    donations.sum(:amount)
  end

  def verified
    vouches.count.positive?
  end

  def ratings
    # get a list of ratings from all vouches for this scenario, and its parent scenario if its a child
    ratings = vouches.where("rating is not null").pluck :rating

    ratings += parent_scenario.ratings if is_child

    ratings
  end

  def ratio_for_user(user)
    # need to implement https://github.com/togglepro/pundit-resources or something for user
    # but lkets fake it for now
    # user = User.find(1) if user.nil?
    return 0 if user.nil?
    ratio = 0

    done = user.done.count
    dismissed = user.user_ad_interactions.count

    ratio = done / dismissed unless dismissed.zero?
    ratio
  end

  def is_parent
    parent_scenario.nil?
  end

  def is_child
    !is_parent
  end

  def is_complete
    !vouches.count.zero?
  end
end
