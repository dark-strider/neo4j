class FacesController < ApplicationController
  around_filter Neo4j::Rails::Transaction, only: [:create, :update, :destroy]
  respond_to :html, :json

  def index
    respond_with(@faces = Face.all)
  end

  def show
    respond_with(@face = Face.find(params[:id]))
  end

  def new
    respond_with(@face = Face.new)
  end

  def create
    @face = Face.new(params[:face])

    if @face.save
      flash[:info] = 'Face created'
      respond_with(@face)
    else
      flash[:info] = 'Face not created'
      render :new
    end
  end

  def edit
    respond_with(@face = Face.find(params[:id]))
  end

  def update
    @face = Face.find(params[:id])

    if @face.update_attributes(params[:face])
      flash[:info] = 'Face updated'
      respond_with(@face)
    else
      flash[:info] = 'Face not updated'
      render :edit
    end
  end

  def set
    @face = Face.find(params[:id])
    @selected = Face.selected(@face) # checking only :outgoing relationships
    
    # select @faces without @face itself
      @faces = []
      Face.all.each{ |f| @faces.push(f) unless f == @face }
      
    @countries = Country.all
    respond_with(@face)
  end

  def setup
    @face = Face.find(params[:id])
    flash[:info] = Face.face_use(@face, params)
    respond_with(@face)
  end

  def destroy
    @face = Face.find(params[:id])
    @face.destroy
    flash[:info] = 'Face deleted'
    respond_with(@face)
  end
end