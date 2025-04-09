class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = current_user.clients.order(created_at: :desc)
  end

  def show
    @devis = @client.devis.order(created_at: :desc)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    @client.status = 'prospect' unless @client.status.present?

    if @client.save
      redirect_to @client, notice: 'Client créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Client mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy!
    redirect_to clients_path, notice: 'Client supprimé avec succès.', status: :see_other
  end

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:first_name, :last_name, :company_name, :email, :phone, :notes, :status)
  end
end