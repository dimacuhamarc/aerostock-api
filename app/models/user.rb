class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  # Pre fill employee_id with a random number
  before_validation :pre_fill_employee_id
  after_commit :send_welcome_email

  # Validations
  
  # validates :first_name, presence: true
  # validates :last_name, presence: true
  validates :email, :first_name, :last_name, presence: true
  validates :employee_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  private 

  def pre_fill_employee_id # AER_12414, EMPLOYEE_ID IS STRING
    loop do
      self.employee_id ||= "AER_#{SecureRandom.random_number(1_000)}"
      break unless User.exists?(employee_id: self.employee_id)
    end
  end

  def send_welcome_email
    AerostockDeviseMailer.welcome_email(self).deliver_now
  end
end
