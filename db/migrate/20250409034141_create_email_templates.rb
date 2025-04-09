class CreateEmailTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :email_templates do |t|
      t.string :name, null: false
      t.string :category
      t.string :subject, null: false
      t.text :content, null: false
      t.json :variables, default: {}
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :email_templates, [:user_id, :category]
    add_index :email_templates, :name
  end
end