class OfferTemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_offer_template, only: [:show, :edit, :update, :destroy]
    
    # GET /offer_templates
    def index
      @offer_templates = current_user.offer_templates.order(created_at: :desc)
    end
    
    # GET /offer_templates/new
    def new
      @offer_template = current_user.offer_templates.build
    end
    
    # POST /offer_templates
    def create
      @offer_template = current_user.offer_templates.build(offer_template_params)
      
      if @offer_template.save
        redirect_to offer_templates_path, notice: "Votre template d'offre a été créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    # GET /offer_templates/:id
    def show
    end
    
    # GET /offer_templates/:id/edit
    def edit
    end
    
    # PATCH/PUT /offer_templates/:id
    def update
      if @offer_template.update(offer_template_params)
        redirect_to offer_template_path(@offer_template), notice: "Votre template d'offre a été mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    # DELETE /offer_templates/:id
    def destroy
      @offer_template.destroy
      redirect_to offer_templates_path, notice: "Le template d'offre a été supprimé avec succès."
    end
    
    private
    
    def set_offer_template
      @offer_template = current_user.offer_templates.find(params[:id])
    end
    
    def offer_template_params
      params.require(:offer_template).permit(
        :name, :content, :category, :location, 
        :capacity_min, :capacity_max, :base_price,
        metadata: {}
      )
    end
  end