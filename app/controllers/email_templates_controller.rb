class EmailTemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_email_template, only: [:show, :edit, :update, :destroy, :preview]
    
    # GET /email_templates
    def index
      @email_templates = current_user.email_templates.order(created_at: :desc)
    end
    
    # GET /email_templates/new
    def new
      @email_template = current_user.email_templates.build
    end
    
    # POST /email_templates
    def create
      @email_template = current_user.email_templates.build(email_template_params)
      
      if @email_template.save
        redirect_to email_templates_path, notice: "Votre template d'email a été créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    # GET /email_templates/:id
    def show
    end
    
    # GET /email_templates/:id/edit
    def edit
    end
    
    # PATCH/PUT /email_templates/:id
    def update
      if @email_template.update(email_template_params)
        redirect_to email_template_path(@email_template), notice: "Votre template d'email a été mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    # DELETE /email_templates/:id
    def destroy
      @email_template.destroy
      redirect_to email_templates_path, notice: "Le template d'email a été supprimé avec succès."
    end
    
    # GET /email_templates/:id/preview
    def preview
      # Créer un hash de paramètres fictifs pour la prévisualisation
      preview_params = {
        'client_name' => 'Nom du Client',
        'event_date' => '15 juillet 2025',
        'company_name' => 'Entreprise ABC',
        'offer_title' => 'Séminaire de Direction',
        'amount' => '1500€'
        # Ajoutez d'autres variables selon vos besoins
      }
      
      @preview_subject = @email_template.fill_subject(preview_params)
      @preview_content = @email_template.fill_content(preview_params)
      
      render :preview
    end
    
    private
    
    def set_email_template
      @email_template = current_user.email_templates.find(params[:id])
    end
    
    def email_template_params
      params.require(:email_template).permit(:name, :category, :subject, :content)
    end
  end