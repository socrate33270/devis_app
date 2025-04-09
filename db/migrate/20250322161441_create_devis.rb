class CreateDevis < ActiveRecord::Migration[8.0]
  def change
    create_table :devis do |t|
      t.string :titre
      t.text :description
      t.string :statut

      t.timestamps
    end
  end
end
