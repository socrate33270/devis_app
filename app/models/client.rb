class Client < ApplicationRecord
  belongs_to :user, optional: true
  has_many :devis, dependent: :destroy  # Ajoutez dependent: :destroy ici
  
  # Méthode utile pour afficher le nom complet
  def full_name
    "#{first_name} #{last_name}"
  end
  
  # Méthode pour afficher le nom avec l'entreprise
  def full_name_with_company
    company_name.present? ? "#{full_name} (#{company_name})" : full_name
  end
end