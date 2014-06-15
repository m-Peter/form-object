class Form
  include ActiveModel::Validations

  attr_reader :association_name, :parent, :model, :name

  def initialize(args)
    @association_name = args[:assoc_name]
    @parent = args[:parent]
    if args[:model]
      @model = args[:model]
    else
      @model = build_model
    end
    self.class_eval &args[:proc]
  end

  def submit(params)
    model.attributes = params
  end

  def valid?
    super
    model.valid?
    collect_errors_from(model)
    errors.empty?
  end

  def id
    model.id
  end

  def persisted?
    model.persisted?
  end

  def represents?(assoc_name)
    association_name.to_s == assoc_name.to_s
  end
  
  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    alias_method :attribute, :attributes
  end

  private

  def build_model
    association_reflection = parent.class.reflect_on_association(association_name)
    association_reflection.autosave = true
    macro = association_reflection.macro

    case macro
    when :has_one
      if parent.send("#{association_name}")
        model = parent.send("#{association_name}")
      else
        model_class = association_name.to_s.camelize.constantize
        model = model_class.new
        parent.send("#{association_name}=", model)
      end
    when :has_many
      parent.send(association_name).build
    end
    
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end
end
