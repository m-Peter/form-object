class Form
  include ActiveModel::Validations

  attr_reader :association_name, :parent, :model, :forms

  def initialize(assoc_name, parent, proc, model=nil)
    @association_name = assoc_name
    @parent = parent
    @model = assign_model(model)
    @forms = []
    self.class_eval &proc
    enable_autosave
    populate_forms
  end

  def submit(params)
    params.each do |key, value|
      if value.is_a?(Hash)
        fill_association_with_attributes(key, value)
      else
        model.send("#{key}=", value)
      end
    end
  end

  def valid?
    super
    model.valid?

    collect_errors_from(model)
    aggregate_form_errors
    
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

    def association(name, &block)
      forms << FormDefinition.new({assoc_name: name, proc: block})
      attr_reader name
      define_method("#{name}_attributes=") {}
    end

    def forms
      @@forms ||= []
    end

    alias_method :attribute, :attributes
  end

  private

  ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

  def fill_association_with_attributes(association, attributes)
    assoc_name = find_association_name_in(association).to_sym

    forms.each do |form|
      if form.represents?(assoc_name)
        form.submit(attributes)
      end
    end
  end

  def find_association_name_in(key)
    ATTRIBUTES_KEY_REGEXP.match(key)[1]
  end

  def populate_forms
    self.class.forms.each do |definition|
      definition.parent = model
      form = definition.to_form
      return unless form
      forms << form
      name = definition.assoc_name
      instance_variable_set("@#{name}", form)
    end
  end

  def association_reflection
    parent.class.reflect_on_association(association_name)
  end

  def enable_autosave
    reflection = association_reflection
    reflection.autosave = true
  end

  def build_model
    macro = association_reflection.macro

    case macro
    when :has_one
      fetch_or_initialize_model
    when :has_many
      parent.send(association_name).build
    end
  end

  def fetch_or_initialize_model
    if parent.send("#{association_name}")
      model = parent.send("#{association_name}")
    else
      model_class = association_name.to_s.camelize.constantize
      model = model_class.new
      parent.send("#{association_name}=", model)
    end
  end

  def assign_model(model)
    if model
      model
    else
      build_model
    end
  end

  def aggregate_form_errors
    forms.each do |form|
      form.valid?
      collect_errors_from(form)
    end
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end
end
