module FormObject
  class Base
    include ActiveModel::Conversion
    include ActiveModel::Validations
    extend ActiveModel::Naming

    attr_reader :model
    
    def initialize(model)
      @model = model
    end

    def persisted?
      @model.persisted?
    end

    def to_key
      return nil unless persisted?
      @model.id
    end

    def to_model
      @model
    end

    def to_param
      return nil unless persisted?
      @model.id.to_s
    end

    def valid?
      result = super
      valid = @model.valid? && result
      
      @model.errors.each do |attribute, error|
        errors.add(attribute, error)
      end

      valid
    end

    def save(params)
      @model.attributes = params

      if valid?
        if @model.persisted?
          @model.update params
        else
          @model.save
        end
      else
        false
      end
    end

    def to_partial_path
      ""
    end

    def method_missing(*args, &block)
      if @model
        @model.send(*args, &block)
      else
        super
      end
    end

    def self.attributes(*names)
      names.each do |name|
        delegate name, to: :model
        delegate "#{name}=", to: :model
      end
    end

  end
end