class Company < Neo4j::Rails::Model

  # -Relationships-
  has_one(:from).to(Country)
  has_many(:worker).to(Face).relationship(Incompany)

  # -Relation validations-
  validates_associated :from, :worker

  # -Fields-
  property :name, type: String, index: :exact

  # -Validations-
  validates :name, presence: true,
                   length: { minimum: 3, maximum: 20 }

  private

  # 'companies / set'
  def self.selected(company)
    hash = { country: Relationship::existing(company, 'Company#from') }
  end

  # 'companies / setup'
  def self.company_use(company, params)
    saved, change = false, []

    tx = Neo4j::Transaction.new
      change << Relationship::has_one(company, 'Company#from', 'Country', params[:country])
      saved = company.save if change.include?(true)
    tx.success
    tx.finish
    saved ? 'Relations changed' : 'Relations not changed'
  end
end