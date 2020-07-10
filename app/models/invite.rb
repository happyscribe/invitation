# An invitation, tracks the sender and recipient, and what the recipient is invited to.
# Generates a unique token for each invitation. The token is used in the invite url
# to (more) securely identify the invite when a new user clicks to register.
#
class Invite < ActiveRecord::Base
  belongs_to :invitable, polymorphic: true
  belongs_to :sender, class_name: Invitation.configuration.user_model_class_name

  # Rails >= 5 makes belongs_to association required by default
  if Rails::VERSION::MAJOR >= 5
    belongs_to :recipient, class_name: Invitation.configuration.user_model_class_name, optional: true
  else
    belongs_to :recipient, class_name: Invitation.configuration.user_model_class_name
  end

  before_create :generate_token
  before_save :set_email_case, on: :create
  before_save :check_recipient_existence

  validates :email, presence: true
  validates :invitable, presence: true
  validates :sender, presence: true
  validate :organization_workspace_can_only_invite_members
  validate :not_duplicated


  def existing_user?
    recipient != nil
  end

  def generate_token
    self.token = SecureRandom.hex(20).encode('UTF-8')
  end

  def check_recipient_existence
    recipient = Invitation.configuration.user_model.find_by_email(email)
    self.recipient_id = recipient.id if recipient
  end

  private

  def set_email_case
    email.downcase! unless Invitation.configuration.case_sensitive_email
  end

  def organization_workspace_can_only_invite_members
    return if invitable.class != Team
    return if invitable.organization.blank?
    unless invitable.organization.users.where(email: "#{email.strip}").count > 0
      errors.add(:email, "doesn't correspond to an organization member.")
    end
  end

  def not_duplicated
    if invitable.users.where(email: email).count > 0
      errors.add(:user, "is already a member.")
    end
  end
end
