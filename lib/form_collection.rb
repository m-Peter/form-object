class FormCollection
  include ActiveModel::Validations
  include Enumerable

  attr_reader :association_name, :records, :parent, :proc, :forms

  def initialize(assoc_name, parent, proc, records)
    @association_name = assoc_name
    @parent = parent
    @proc = proc
    @records = records
    @forms = []
    assign_forms
  end

  def submit(params)
    #check_record_limit!(records, params)

    params.each do |key, value|
      if parent.persisted?
        id = value[:id]
        if id
          if value[:_destroy] == "1"
            forms.delete_if { |form| form.id == id }
            form = find_form_by_model_id(id)
            form.model.destroy
          else
            value.delete("_destroy")
            form = find_form_by_model_id(id)
            form.submit(value)
          end
        else
          new_form = Form.new(association_name, parent, proc)
          forms << new_form
          new_form.submit(value)
        end
      else
        i = key.to_i
        
        if dynamic_key?(i)
          new_form = Form.new(association_name, parent, proc)
          forms << new_form
          new_form.submit(value)
        else
          forms[i].submit(value)
        end
      end
    end
  end

  def valid?
    aggregate_form_errors

    errors.empty?
  end

  def represents?(assoc_name)
    association_name.to_s == assoc_name.to_s
  end

  def models
    forms
  end

  def each(&block)
    forms.each do |form|
      block.call(form)
    end
  end

  private

  def assign_forms
    if parent.persisted?
      fetch_models
    else
      initialize_models
    end
  end

  def dynamic_key?(i)
    i > forms.size
  end

  def aggregate_form_errors
    forms.each do |form|
      form.valid?
      collect_errors_from(form)
    end
  end

  def fetch_models
    associated_records = parent.send(association_name)
    
    associated_records.each do |model|
      forms << Form.new(association_name, parent, proc, model)
    end
  end

  def initialize_models
    records.times do
      forms << Form.new(association_name, parent, proc)
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

  def find_form_by_model_id(id)
    forms.each do |form|
      if form.id == id.to_i
        return form
      end
    end
  end

  def delete_form_by_model_id(id)
    forms.each do |form|
      if form.id == id.to_i
        
      end
    end
  end
end