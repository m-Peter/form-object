class FormDefinition
  attr_accessor :assoc_name, :proc, :parent
  
  def initialize(args)
    args.each do |key, value|
      send("#{key}=", value)
    end
  end

  def to_form
    Form.new({assoc_name: assoc_name, proc: proc, parent: parent})
  end
end