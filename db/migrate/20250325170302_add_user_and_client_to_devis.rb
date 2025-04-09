class AddUserAndClientToDevis < ActiveRecord::Migration[8.0]
  def change
    add_reference :devis, :user, null: true, foreign_key: true
    add_reference :devis, :client, null: true, foreign_key: true
  end
end