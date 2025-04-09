class Devis < ApplicationRecord
    # Un devis appartient à un utilisateur et un client
    belongs_to :user, optional: true
    belongs_to :client, optional: true
    
    # Ajouter cette ligne pour l'association avec les offres
    has_many :offers, dependent: :destroy
    
    # Nous rendons ces relations optionnelles (avec optional: true)
    # pour assurer la compatibilité avec vos devis existants
  end