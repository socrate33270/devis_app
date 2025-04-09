class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # Associations avec les autres modèles
  has_many :devis
  has_many :clients
  has_many :offer_templates, dependent: :destroy
  has_many :email_templates, dependent: :destroy
end