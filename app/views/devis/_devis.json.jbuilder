json.extract! devis, :id, :titre, :description, :statut, :created_at, :updated_at
json.url devis_url(devis, format: :json)
