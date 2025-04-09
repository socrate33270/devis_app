class EmailTemplate < ApplicationRecord
    belongs_to :user
    
    # Validations
    validates :name, presence: true
    validates :subject, presence: true
    validates :content, presence: true
    
    # Catégories disponibles
    CATEGORIES = ['suivi_client', 'confirmation', 'relance', 'traiteur', 'hotel', 'salle', 'activite', 'autre']
    
    # Scopes pour filtrer facilement
    scope :by_category, ->(category) { where(category: category) }
    
    # Méthode pour remplacer les variables dans le contenu
    def fill_content(params = {})
      result = content.dup
      
      # Remplacer chaque variable par sa valeur
      params.each do |key, value|
        result.gsub!(/\{\{#{key}\}\}/, value.to_s)
      end
      
      result
    end
    
    # Méthode pour remplacer les variables dans l'objet
    def fill_subject(params = {})
      result = subject.dup
      
      # Remplacer chaque variable par sa valeur
      params.each do |key, value|
        result.gsub!(/\{\{#{key}\}\}/, value.to_s)
      end
      
      result
    end
  end