class FormCollection
  include ActiveModel::Validations
  include Enumerable

  attr_reader :association_name, :records, :parent

  def initialize(args)
    @association_name = args[:assoc_name]
    @records = args[:records]
    @parent = args[:parent]
    @proc = args[:proc]
    @models = []
    assign_models
  end

  def submit(params)
    check_record_limit!(records, params)

    params.each do |key, value|
      if parent.persisted?
        id = value[:id]
        model = find_model(id)
        model.submit(value)
      else
        i = key.to_i
        @models[i].submit(value)
      end
    end
  end

  def valid?
    @models.each do |model|
      model.valid?
      collect_errors_from(model)
    end

    errors.empty?
  end

  def represents?(assoc_name)
    association_name.to_s == assoc_name.to_s
  end

  def models
    @models
  end

  def each(&block)
    @models.each do |form|
      block.call(form)
    end
  end

  private

  def assign_models
    if parent.persisted?
      fetch_models
    else
      initialize_models
    end
  end

  def fetch_models
    associated_records = parent.send(association_name)
    associated_records.each do |model|
      args = {assoc_name: @association_name, parent: @parent, proc: @proc, model: model}
      @models << Form.new(args)
    end
  end

  def initialize_models
    records.times do
      args = {assoc_name: @association_name, parent: @parent, proc: @proc}
      @models << Form.new(args)
    end
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end

  def check_record_limit!(limit, attributes_collection)
    if attributes_collection.size > limit
      raise TooManyRecords, "Maximum #{limit} records are allowed. Got #{attributes_collection.size} records instead."
    end
  end

  def find_model(id)
    @models.each do |model|
      if model.id == id.to_i
        return model
      end
    end
  end
end