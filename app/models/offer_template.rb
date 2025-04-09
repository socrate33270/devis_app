class OfferTemplate < ApplicationRecord
    belongs_to :user
    
    # Validations
    validates :name, presence: true
    validates :content, presence: true
    validates :category, presence: true
    
    # Catégories disponibles
    CATEGORIES = ['hotel', 'restaurant', 'salle', 'activite', 'transport', 'autre']
    
    # Scopes pour filtrer facilement
    scope :by_category, ->(category) { where(category: category) }
    scope :by_location, ->(location) { where("location LIKE ?", "%#{location}%") }
    scope :by_capacity, ->(size) { where("capacity_min <= ? AND capacity_max >= ?", size, size) if size.present? }
    
    # Méthode pour trouver des templates correspondant à certains critères
    def self.find_matching(params = {})
      templates = all
      
      # Filtrer par utilisateur si spécifié
      templates = templates.where(user_id: params[:user_id]) if params[:user_id].present?
      
      # Filtrer par catégorie si spécifiée
      templates = templates.by_category(params[:category]) if params[:category].present?
      
      # Filtrer par lieu si spécifié
      templates = templates.by_location(params[:location]) if params[:location].present?
      
      # Filtrer par capacité si spécifiée
      templates = templates.by_capacity(params[:capacity]) if params[:capacity].present?
      
      templates
    end
  end