class CollectionForm
  include ActiveModel::Validations
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
      if parent.persisted?
        id = value[:id]
        #model = @models.find(id)
        #model.attributes = value
        #model.save
        model = find_model(id)
        model.submit(value)
        model.save
      else
        i = key.to_i
        @models[i].submit(value)
      end
    end
  end

  def find_model(id)
    @models.each do |model|
      if model.id == id.to_i
        return model
      end
    end
  end

  def valid?
    @models.each do |model|
      model.valid?
      model.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
    errors.empty?
  end

  def build_models
    if parent.persisted?
      #@models = parent.send(association_name)
      associated_records = parent.send(association_name)
      associated_records.each do |model|
        args = {assoc_name: @association_name, parent: @parent, proc: @proc, model: model}
        @models << SubForm.new(args)
      end
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