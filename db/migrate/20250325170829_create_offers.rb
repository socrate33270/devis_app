class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers do |t|
      t.references :devis, null: false, foreign_key: true
      t.text :content
      t.text :original_content
      t.boolean :edited

      t.timestamps
    end
  end
end
