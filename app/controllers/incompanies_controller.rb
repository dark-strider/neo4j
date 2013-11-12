class IncompaniesController < ApplicationController
  around_filter Neo4j::Rails::Transaction, only: [:create, :update, :destroy]
  respond_to :html, :json

  def new
    @company = Company.find(params[:company_id])
    @face = Face.all
    @incompany = Incompany.new
    respond_with(@incompany)
  end

  def create
    @company = Company.find(params[:company_id])
    @face = Face.find(params[:face_id])
    @incompany = @company.worker_rels.connect(@face, params[:incompany])

    if @incompany.save
      flash[:info] = 'Worker created'
      redirect_to [:workers, @company]
    else
      flash[:info] = 'Worker not created'
      @face = Face.all
      render :new
    end
  end

  def edit
    @company = Company.find(params[:company_id])
    @incompany = Incompany.find(params[:id])
    @face = @incompany.end_node
    respond_with(@incompany)
  end

  def update
    @company = Company.find(params[:company_id])
    @incompany = Incompany.find(params[:id])

    if @incompany.update_attributes(params[:incompany])
      flash[:info] = 'Worker updated'
      redirect_to [:workers, @company]
    else
      flash[:info] = 'Worker not updated'
      @face = @incompany.end_node
      render :edit
    end
  end

  def destroy
    @company = Company.find(params[:company_id])
    @incompany = Incompany.find(params[:id])
    @incompany.destroy
    flash[:info] = 'Worker deleted'
    redirect_to [:workers, @company]
  end
end