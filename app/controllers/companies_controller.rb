class CompaniesController < ApplicationController
  around_filter Neo4j::Rails::Transaction, only: [:create, :update, :destroy]
  respond_to :html, :json

  def index
    respond_with(@companies = Company.all)
  end

  def new
    respond_with(@company = Company.new)
  end

  def create
    @company = Company.new(params[:company])

    if @company.save
      flash[:info] = 'Company created'
      redirect_to :companies
    else
      flash[:info] = 'Company not created'
      render :new
    end
  end

  def edit
    respond_with(@company = Company.find(params[:id]))
  end

  def update
    @company = Company.find(params[:id])

    if @company.update_attributes(params[:company])
      flash[:info] = 'Company updated'
      redirect_to :companies
    else
      flash[:info] = 'Company not updated'
      render :edit
    end
  end

  def set
    @company = Company.find(params[:id])
    @selected = Company.selected(@company)
    @countries = Country.all
    respond_with(@company)
  end

  def setup
    @company = Company.find(params[:id])
    flash[:info] = Company.company_use(@company, params)
    redirect_to :companies
  end

  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    flash[:info] = 'Company deleted'
    respond_with(@company)
  end

  def workers
    respond_with(@company = Company.find(params[:id]))
  end
end