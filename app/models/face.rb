class Face < Neo4j::Rails::Model

  # -Relationships-
  has_one(:from).to(Country)
  has_many(:friends).to(Face)
  has_many(:hasCompanies).from(Company, :worker)

  # -Relation validations-
  validates_associated :from, :friends

  # -Fields-
  property :name, type: String, index: :exact

  # -Validations-
  validates :name, presence: true,
                   length: { minimum: 3, maximum: 20 }

  private

  # 'faces / set'
  def self.selected(face)
    hash = {
      country: Relationship::existing(face, 'Face#from'),
      friends: Relationship::existing(face, 'Face#friends') }
  end

  # 'faces / setup'
  def self.face_use(face, params)
    saved, change = false, []

    tx = Neo4j::Transaction.new
      change << Relationship::has_one(face, 'Face#from', 'Country', params[:country])
      change << Relationship::has_many(face, 'Face#friends', 'Face', params[:friends])
      saved = face.save if change.include?(true)
    tx.success
    tx.finish
    saved ? 'Relations changed' : 'Relations not changed'
  end
end