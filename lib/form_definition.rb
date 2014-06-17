class FormDefinition
  attr_accessor :assoc_name, :proc, :parent, :records
  
  def initialize(args)
    args.each do |key, value|
      send("#{key}=", value)
    end
  end

  def to_form
    if is_plural?(assoc_name.to_s)
      FormCollection.new({assoc_name: assoc_name, proc: proc, parent: parent, records: records})
    else
      Form.new({assoc_name: assoc_name, proc: proc, parent: parent})
    end
  end

  def is_plural?(str)
    str.pluralize == str
  end
end