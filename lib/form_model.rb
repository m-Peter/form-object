class FormModel
  include ActiveModel::Model
  
  attr_reader :model, :forms

  def initialize(model)
    @model = model
    @forms = []
    populate_forms
  end

  def populate_forms
    self.class.forms.each do |definition|
      definition[:parent] = model
      sub_form = SubForm.new(definition)
      @forms << sub_form
      instance_variable_set("@#{definition[:assoc_name]}", sub_form)
    end
  end

  def submit(params)
    email_params = params.delete(:email)
    params.each do |key, value|
      send("#{key}=", value)
    end
    @forms.each do |form|
      form.submit(email_params)
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        @model.save
      end
    else
      false
    end
  end

  def valid?
    super
    @model.valid?
    @model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
    @forms.each do |form|
      form.valid?
      form.errors.each do |attribute, error|
        errors.add(attribute, error)
      end
    end
    errors.empty?
  end

  def persisted?
    @model.persisted?
  end

  def to_key
    return nil unless persisted?
    @model.id
  end

  def to_param
    return nil unless persisted?
    @model.id.to_s
  end

  def to_partial_path
    ""
  end

  def to_model
    @model
  end

  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    def association(name, &block)
      forms << {assoc_name: name, proc: block}
      attr_reader name
    end

    def forms
      @@forms ||= []
    end
  end
end