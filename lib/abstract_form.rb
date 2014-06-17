class AbstractForm
  include ActiveModel::Model
  
  attr_reader :model, :forms

  def initialize(model)
    @model = model
    @forms = []
    populate_forms
  end
  
  def submit(params)
    params.each do |key, value|
      if value.is_a?(Hash)
        fill_association_with_attributes(key, value)
      else
        send("#{key}=", value)
      end
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        model.save
      end
    else
      false
    end
  end

  def valid?
    super
    model.valid?

    collect_errors_from(model)
    aggregate_form_errors
    
    errors.empty?
  end

  def persisted?
    model.persisted?
  end

  def to_key
    return nil unless persisted?
    model.id
  end

  def to_param
    return nil unless persisted?
    model.id.to_s
  end

  def to_partial_path
    ""
  end

  def to_model
    model
  end

  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    alias_method :attribute, :attributes

    def association(name, options={}, &block)
      if is_plural?(name.to_s)
        collection(name, options, &block)
      else  
        form(name, &block)
      end
    end

    def collection(name, options={}, &block)
      forms << FormDefinition.new({assoc_name: name, records: options[:records], proc: block})
      self.class_eval("def #{name}; @#{name}.models; end")
      define_method("#{name}_attributes=") {}
    end

    def form(name, &block)
      forms << FormDefinition.new({assoc_name: name, proc: block})
      attr_reader name
      define_method("#{name}_attributes=") {}
    end

    def forms
      @forms ||= []
    end

    def is_plural?(str)
      str.pluralize == str
    end
  end

  private

  def populate_forms
    self.class.forms.each do |definition|
      definition.parent = model
      form = definition.to_form
      forms << form
      name = definition.assoc_name
      instance_variable_set("@#{name}", form)
    end
  end

  ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

  def macro_for_association(association)
    association_name = find_association_name_in(association).to_sym
    association_reflection = model.class.reflect_on_association(association_name)
    association_reflection.macro
  end

  def find_association_name_in(key)
    ATTRIBUTES_KEY_REGEXP.match(key)[1]
  end

  def fill_association_with_attributes(association, attributes)
    assoc_name = find_association_name_in(association).to_sym

    forms.each do |form|
      if form.represents?(assoc_name)
        form.submit(attributes)
      end
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
