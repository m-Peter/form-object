class CollectionForm
  include Enumerable

  attr_reader :association_name, :records, :parent

  def initialize(args)
    @association_name = args[:assoc_name]
    @records = args[:records]
    @parent = args[:parent]
    @proc = args[:proc]
    @models = []
    build_models
  end

  def submit(params)
    params.each do |key, value|
      i = key.to_i
      @models[i].submit(value)
    end
  end

  def build_models
    if parent.persisted?
      @models = parent.send(association_name)
    else
      records.times do
        args = {assoc_name: @association_name, parent: @parent, proc: @proc}
        @models << SubForm.new(args)
      end
    end
  end

  def models
    @models
  end

  def each(&block)
    @models.each do |form|
      block.call(form)
    end
  end
end