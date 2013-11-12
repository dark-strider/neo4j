class Incompany < Neo4j::Rails::Relationship

  # -Fields-
  property :job, type: String, index: :exact

  # -Validations-
  validates :job, presence: true,
                  length: { minimum: 3, maximum: 20 }
end