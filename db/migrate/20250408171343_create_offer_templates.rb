class CreateOfferTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :offer_templates do |t|
      t.string :name, null: false
      t.text :content, null: false
      t.string :category, null: false  # ex: "hotel", "restaurant", "salle"
      t.string :location  # ville ou région 
      t.integer :capacity_min
      t.integer :capacity_max
      t.decimal :base_price, precision: 10, scale: 2
      t.json :metadata  # pour stocker des infos supplémentaires selon le type
      t.references :user, null: false, foreign_key: true  # l'utilisateur propriétaire

      t.timestamps
    end
    
    # Index pour recherche rapide
    add_index :offer_templates, [:user_id, :category]
    add_index :offer_templates, :location
  end
end