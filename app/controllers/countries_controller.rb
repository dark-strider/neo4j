class CountriesController < ApplicationController
  around_filter Neo4j::Rails::Transaction, only: [:create, :update, :destroy]
  respond_to :html, :json

  def index
    respond_with(@countries = Country.all)
  end

  def new
    respond_with(@country = Country.new)
  end

  def create
    @country = Country.new(params[:country])

    if @country.save
      flash[:info] = 'Country created'
      redirect_to :countries
    else
      flash[:info] = 'Country not created'
      render :new
    end
  end

  def edit
    respond_with(@country = Country.find(params[:id]))
  end

  def update
    @country = Country.find(params[:id])

    if @country.update_attributes(params[:country])
      flash[:info] = 'Country updated'
      redirect_to :countries
    else
      flash[:info] = 'Country not updated'
      render :edit
    end
  end

  def destroy
    @country = Country.find(params[:id])
    @country.destroy
    flash[:info] = 'Country deleted'
    respond_with(@country)
  end
end