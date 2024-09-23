class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  before_create :process_before_validation

  before_validation :process_before_validation

  after_create_commit :send_welcome_email

  validates :email, :first_name, :last_name, presence: true
  validates :employee_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def generate_jwt_token
    JWT.encode({ user_id: self.id, exp: 24.hours.from_now.to_i }, Rails.application.secrets.devise_jwt_secret_key!)
  end
  
  private 

  def pre_fill_employee_id # AER_12414, EMPLOYEE_ID IS STRING
    if self.employee_id.blank?
      loop do
        self.employee_id ||= "AER_#{SecureRandom.random_number(1_000)}"
        break unless User.exists?(employee_id: self.employee_id)
      end
    end
  end

  def pre_assign_role # Defaults as a Guest
    self.add_role(:guest) if self.roles.blank?
  end

  def send_welcome_email
    AerostockDeviseMailer.welcome_email(self).deliver_now
  end

  def must_have_single_role
    errors.add(:roles, "must have a single role") if roles.size == 1
  end

  def process_before_validation
    pre_fill_employee_id
    pre_assign_role
  end

  
end
