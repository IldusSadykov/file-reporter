class Parser
  attr_reader :entity, :fields

  def initialize(entity, fields)
    @entity = entity
    @fields = fields
  end

  def execute
    Hash[fields.zip(entity)]
  end
end
