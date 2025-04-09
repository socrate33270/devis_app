class DevisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_devis, only: %i[ show edit update destroy generate_offer set_territoire set_type_offre update_offer show_original_offer download_offer_pdf ]

  # GET /devis/1 or /devis/1.json
  def show
  end

  # GET /clients/:client_id/devis/new
  def new
    @client = Client.find(params[:client_id])
    @devis = Devis.new(client_id: @client.id)
  end

  # GET /devis/1/edit
  def edit
    @client = @devis.client if @devis.client_id.present?
  end

  # POST /clients/:client_id/devis
  def create
    @client = Client.find(params[:client_id])
    
    # Ne garder que les attributs qui existent dans le modèle Devis
    @devis = Devis.new(devis_params)
    @devis.client = @client
    @devis.user = current_user
    
    # Sauvegarder les options d'IA dans la session au lieu du modèle
    session[:territoire_id] = params[:devis][:territoire_id] if params[:devis][:territoire_id].present?
    session[:type_offre] = params[:devis][:type_offre] if params[:devis][:type_offre].present?
    
    respond_to do |format|
      if @devis.save
        if params[:generate_with_ai] == "true"
          # Rediriger vers la génération d'offre
          format.html { redirect_to generate_offer_devis_path(@devis) }
        else
          # Redirection normale
          format.html { redirect_to @devis, notice: "Devis créé avec succès." }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /devis/1 or /devis/1.json
  def update
    respond_to do |format|
      if @devis.update(devis_params)
        format.html { redirect_to @devis, notice: "Devis was successfully updated." }
        format.json { render :show, status: :ok, location: @devis }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @devis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /devis/1 or /devis/1.json
  def destroy
    @devis.destroy!
    
    respond_to do |format|
      format.html { redirect_to devis_index_path, status: :see_other, notice: "Devis was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  # GET /devis/1/generate_offer
  def generate_offer
    require 'net/http'
    require 'json'
    
    # Initialiser @offer comme un nouvel objet avant tout traitement
    @offer = @devis.offers.build
    
    # Récupération de la clé API et des paramètres de personnalisation
    api_key = ENV["HUGGINGFACE_API_KEY"]
    territoire_id = session[:territoire_id] || "bordeaux"
    type_offre = session[:type_offre] || "groupes"  # Ajout important pour le type d'offre
    
    # Extraction du nombre de participants depuis la description
    nombre_participants = extract_participant_count(@devis.description)
    
    # Ajout de logs pour déboguer
    Rails.logger.info("Territoire sélectionné: #{territoire_id}")
    Rails.logger.info("Type d'offre: #{type_offre}")
    Rails.logger.info("Nombre de participants détecté: #{nombre_participants || 'Aucun'}")
    
    # Classement de la taille du groupe
    taille_groupe = if nombre_participants.nil?
                      "indéterminée"
                    elsif nombre_participants < 10
                      "petit groupe"
                    elsif nombre_participants < 30
                      "groupe moyen"
                    else
                      "grand groupe"
                    end
    
    begin
      # Chargement des données du territoire
      fichier_path = Rails.root.join('data', 'territoires', "#{territoire_id}.json").to_s
      Rails.logger.info("Chemin du fichier: #{fichier_path}")
      territoire_json = File.read(fichier_path)
      territoire = JSON.parse(territoire_json)
      
      # Sélection des offres les plus pertinentes selon le type et la taille
      offres_pertinentes = []
      if territoire["offres"] && territoire["offres"][type_offre]
        offres_disponibles = territoire["offres"][type_offre]
        
        # Filtrage par capacité si on connaît le nombre de participants
        if nombre_participants
          offres_disponibles.each do |offre|
            # Convertir explicitement en entiers pour éviter les erreurs de type
            capacite_min = offre["capacite_min"].to_i
            capacite_max = offre["capacite_max"].to_i
            
            Rails.logger.info("Offre: #{offre['nom']} - min: #{capacite_min}, max: #{capacite_max}, participants: #{nombre_participants}")
            
            if capacite_min <= nombre_participants && capacite_max >= nombre_participants
              offres_pertinentes << offre
            end
          end
        end   
        # Si aucune offre ne correspond exactement, on prend les 2 plus proches
        if offres_pertinentes.empty?
          offres_pertinentes = offres_disponibles.first(2)
        end
      end
      
      # Préparation du texte pour le prompt
      offres_txt = offres_pertinentes.map do |offre|
        avantages = offre["avantages"] ? " | Avantages: #{offre["avantages"].join(', ')}" : ""
        "- #{offre['nom']}: #{offre['description']} (#{offre['prix_par_personne']}€/personne)#{avantages}"
      end.join("\n")
      
      # Faire de même pour les hébergements...
      hebergements_pertinents = []
      if territoire["hebergements"] && territoire["hebergements"][type_offre]
        # Logique similaire pour les hébergements...
      end
      
      # Construction du prompt
# Récupérer les templates d'offres personnalisées de l'utilisateur
user_templates = current_user.offer_templates.find_matching(
  location: territoire_id,
  capacity: nombre_participants
)

# Préparer les templates personnalisés pour le prompt
user_templates_txt = ""
if user_templates.present?
  user_templates_txt = user_templates.map do |template|
    "- #{template.name}: #{template.content.truncate(200)} " +
    "(Catégorie: #{template.category.capitalize}, " +
    "Prix: #{template.base_price}€, " +
    "Capacité: #{template.capacity_min}-#{template.capacity_max} personnes)"
  end.join("\n")
end

      prompt = "Tu es l'assistant de l'Office de Tourisme de #{territoire['nom']} (#{territoire['region']}). " \
               "Réponds UNIQUEMENT en français comme si tu représentais officiellement cet office.\n\n" \
               "Voici la demande client :\n" \
               "Titre : #{@devis.titre}\n" \
               "Description : #{@devis.description}\n" \
               "Statut : #{@devis.statut}\n\n" \
               "Informations détectées :\n" \
               "- Type de groupe : #{type_offre.capitalize}\n" \
               "- Nombre de participants : #{nombre_participants || 'Non spécifié'}\n" \
               "- Taille du groupe : #{taille_groupe}\n\n" \
               "Voici les offres les plus adaptées à ce groupe :\n" \
               "#{offres_txt}\n\n" \
               # Ajouter les templates personnalisés au prompt s'ils existent
if user_templates.present?
  prompt += "Voici les offres personnalisées de cet établissement :\n" +
            "#{user_templates_txt}\n\n" +
            "IMPORTANT: Ces offres personnalisées doivent être intégrées en priorité dans ta proposition.\n\n"
end
               "Rédige une proposition commerciale personnalisée et convaincante qui :\n" \
               "1. S'adresse directement aux besoins exprimés dans la demande\n" \
               "2. Présente les offres les plus pertinentes de manière attrayante\n" \
               "3. Suggère un programme cohérent en fonction du type de groupe\n" \
               "4. Fournit une estimation budgétaire claire\n" \
               "5. Propose une prochaine étape concrète\n\n" \
               "Ton texte doit être professionnel, chaleureux et vraiment spécifique à la demande."
      
      # Préparation de la requête API
      uri = URI("https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2")
      
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{api_key}"
      req["Content-Type"] = "application/json"
      
      req.body = {
        inputs: prompt,
        parameters: {
          max_new_tokens: 1000,
          temperature: 0.75,
          return_full_text: false
        }
      }.to_json
      
      # Affichage d'un message dans les logs
      Rails.logger.info("Envoi d'une requête à Hugging Face API")
      
      # Envoi de la requête à Hugging Face
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 60  # Augmenté car les réponses plus longues prennent plus de temps
      res = http.request(req)
      
      # Traitement de la réponse
      if res.is_a?(Net::HTTPSuccess)
        Rails.logger.info("Réponse reçue avec succès")
        
        data = JSON.parse(res.body)
        
        # Le format de la réponse est différent de l'API locale
        if data.is_a?(Array) && data[0].is_a?(Hash)
          generated_text = data[0]["generated_text"]
        else
          generated_text = data["generated_text"] || "Format de réponse non reconnu: #{res.body[0..100]}"
        end
        
        # Créer une nouvelle offre
        @offer = @devis.offers.create(
          original_content: generated_text,
          content: generated_text,
          edited: false
        )
        
        # Pour compatibilité avec le template
        @offre = @offer.content
      else
        error_message = "Erreur lors de l'appel à l'IA : Code #{res.code} - #{res.message}"
        
        # Créer une offre avec l'erreur
        @offer = @devis.offers.create(
          original_content: error_message,
          content: error_message,
          edited: false
        )
        
        # Pour compatibilité avec le template
        @offre = error_message
        
        # Afficher plus de détails sur l'erreur
        Rails.logger.error("Erreur API: #{res.body}")
      end
    rescue StandardError => e
      error_message = "Erreur de connexion à l'IA : #{e.class.name} - #{e.message}"
      
      # Créer une offre avec l'erreur
      @offer = @devis.offers.create(
        original_content: error_message,
        content: error_message,
        edited: false
      )
      
      # Pour compatibilité avec le template
      @offre = error_message
      Rails.logger.error("Exception: #{e.backtrace.join("\n")}")
    end
    
    render :show_offer
  end
  
  # PATCH /devis/1/update_offer
  # PATCH /devis/1/update_offer
  def update_offer
    Rails.logger.info("Début update_offer - params: #{params.inspect}")
    
    if params[:manual_creation].present?
      # Code existant pour la création manuelle...
    else
      begin
        @offer = @devis.offers.find(params[:offer_id])
        original_content = @offer.content
        Rails.logger.info("AVANT update - ID: #{@offer.id}, Content: '#{original_content[0..30]}...'")
        
        # Essayer d'appliquer les modifications
        new_content = params[:offer][:content]
        Rails.logger.info("Nouveau contenu reçu: '#{new_content[0..30]}...'")
        
        # Forcer une mise à jour directe de la colonne content
        if @offer.update_column(:content, new_content)
          Rails.logger.info("Mise à jour directe de la colonne réussie!")
          # Marquer comme édité si nécessaire
          @offer.update_column(:edited, true) unless @offer.edited?
          
          # Recharger pour vérifier
          @offer.reload
          Rails.logger.info("APRÈS update - ID: #{@offer.id}, Content: '#{@offer.content[0..30]}...'")
          
          redirect_to show_original_offer_devis_path(@devis, offer_id: @offer.id, t: Time.now.to_i), 
                      notice: "L'offre a été mise à jour avec succès."
        else
          Rails.logger.error("Échec de la mise à jour directe!")
          @offre = original_content
          render :show_offer, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("ERREUR dans update_offer: #{e.message}")
        @offre = @offer&.content || "Erreur lors de la mise à jour"
        render :show_offer, status: :unprocessable_entity
      end
    end
  end
  
  # GET /devis/1/show_original_offer
  def show_original_offer
    @offer = @devis.offers.find(params[:offer_id])
    
    if params[:original] == 'true'
      # Juste afficher l'original sans modifier @offer.content
      @offre = @offer.original_content
    else
      # Afficher le contenu édité
      @offre = @offer.content
    end
    
    render :show_offer
  end
  
  # POST /devis/1/set_territoire
  def set_territoire
    session[:territoire_id] = params[:territoire_id]
    redirect_to @devis, notice: "Territoire changé pour: #{params[:territoire_id].capitalize}"
  end
  
  # POST /devis/1/set_type_offre
  def set_type_offre
    session[:type_offre] = params[:type_offre]
    redirect_to @devis, notice: "Type d'offre changé pour: #{params[:type_offre].capitalize}"
  end

  # GET /devis/1/download_offer_pdf
  def download_offer_pdf
    # Récupérer le devis et l'offre
    @offer = @devis.offers.find(params[:offer_id])
    @offre = @offer.content

    # Générer le PDF
    respond_to do |format|
      format.pdf do
        # Options pour le PDF
        render pdf: "offre_#{@devis.id}",         # Nom du fichier
               template: 'devis/offer_pdf',       # Nom du template à utiliser
               layout: 'pdf',                     # Utiliser le layout pdf
               page_size: 'A4',                   # Format de page
               encoding: 'UTF-8',                 # Encodage pour les accents
               margin: { top: 20,                 # Marges en mm
                        bottom: 20, 
                        left: 20, 
                        right: 20 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_devis
      @devis = Devis.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def devis_params
      params.require(:devis).permit(:titre, :description, :statut, :client_id)
    end
    
    # Paramètres autorisés pour les offres
    def offer_params
      params.require(:offer).permit(:content)
    end

    # Méthode d'extraction du nombre de participants
    def extract_participant_count(description)
      return nil if description.nil?
      
      # Recherche des motifs comme "20 personnes", "15 participants", etc.
      matches = description.scan(/(\d+)\s*(personnes|participants|invités|convives|membres)/i)
      
      if matches.any?
        # Retourne le premier nombre trouvé
        return matches.first[0].to_i
      end
      
      # Valeur par défaut si aucun nombre n'est trouvé
      return nil
    end
end