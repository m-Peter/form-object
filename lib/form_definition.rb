class FormDefinition
  attr_accessor :assoc_name, :proc
  
  def initialize(args)
    args.each do |key, value|
      send("#{key}=", value)
    end
  end
end