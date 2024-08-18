class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  # Pre fill employee_id with a random number
  before_validation :pre_fill_employee_id


  # Validations
  
  # validates :first_name, presence: true
  # validates :last_name, presence: true
  validates :email, :first_name, :last_name, presence: true
  validates :employee_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def pre_fill_employee_id # AER_12414, EMPLOYEE_ID IS STRING
    # self.employee_id ||= SecureRandom.random_number(1_000_000)
    self.employee_id ||= "AER_#{SecureRandom.random_number(1_000)}"
  end
end
