class FormModel
  include ActiveModel::Model
  
  attr_reader :model, :forms, :collections

  def initialize(model)
    @model = model
    @forms = []
    @collections = []
    populate_forms
    populate_collections
  end
  
  def submit(params)
    params.each do |key, value|
      if value.is_a?(Hash)
        assign_to(key, value)
      else
        send("#{key}=", value)
      end
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        model.save
        forms.each do |form|
          form.save
        end
      end
    else
      false
    end
  end

  def valid?
    super
    model.valid?
    collect_errors_from(model)
    collect_forms_errors
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

    def association(name, &block)
      forms << {assoc_name: name, proc: block}
      attr_reader name
      define_method("#{name}_attributes=") {}
    end

    def collection(name, records: 2, &block)
      collections << {assoc_name: name, records: records, proc: block}
      self.class_eval("def #{name}; @#{name}.models; end")
      define_method("#{name}_attributes=") {}
    end

    def collections
      @collections ||= []
    end

    def forms
      @forms ||= []
    end
  end

  private

  def populate_forms
    self.class.forms.each do |definition|
      definition[:parent] = model
      sub_form = SubForm.new(definition)
      forms << sub_form
      instance_variable_set("@#{definition[:assoc_name]}", sub_form)
    end
  end

  def populate_collections
    self.class.collections.each do |definition|
      definition[:parent] = model
      collection_form = CollectionForm.new(definition)
      collections << collection_form
      instance_variable_set("@#{definition[:assoc_name]}", collection_form)
    end
  end

  ATTRIBUTES_KEY_REGEXP = /^(.+)_attributes$/

  def macro_for_attribute_key(key)
    association_name = find_association_name_in(key).to_sym
    association_reflection = model.class.reflect_on_association(association_name)
    association_reflection.macro
  end

  def find_association_name_in(key)
    ATTRIBUTES_KEY_REGEXP.match(key)[1]
  end

  def assign_to(key, value)
    macro = macro_for_attribute_key(key)

    case macro
    when :has_one
      assoc_name = find_association_name_in(key).to_sym
      forms.each do |form|
        if form.association_name.to_s == assoc_name.to_s
          form.submit(value)
        end
      end
    when :has_many
      assoc_name = find_association_name_in(key).to_sym
      collections.each do |collection|
        if collection.association_name.to_s == assoc_name.to_s
          collection.submit(value)
        end
      end
    end
  end

  def collect_errors_from(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end

  def collect_forms_errors
    forms.each do |form|
      form.valid?
      form.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
  end
end
