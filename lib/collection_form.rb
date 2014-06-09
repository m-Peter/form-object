class CollectionForm
  include ActiveModel::Model
  include Enumerable

  attr_reader :association_name, :records, :parent, :models

  def initialize(args)
    @association_name = args[:assoc_name]
    @records = args[:records]
    @parent = args[:parent]
    @proc = args[:proc]
    @models = []
    build_models
  end

  def each(&block)
    @models.each do |form|
      block.call(form)
    end
  end

  def build_models
    records.times do
      args = {assoc_name: association_name, parent: parent, proc: @proc}
      form = SubForm.new(args)
      models << form
    end
  end
end