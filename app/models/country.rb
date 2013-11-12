class Country < Neo4j::Rails::Model

  # -Relationships-
  has_many(:hasCompanies).from(Company, :from)
  has_many(:hasFaces).from(Face, :from)

  # -Fields-
  property :name, type: String, index: :exact

  # -Validations-
  validates :name, presence: true,
                   length: { minimum: 3, maximum: 20 }
end