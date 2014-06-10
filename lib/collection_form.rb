class CollectionForm
  include Enumerable

  attr_reader :association_name, :records, :parent

  def initialize(args)
    @association_name = args[:assoc_name]
    @records = args[:records]
    @parent = args[:parent]
    @proc = args[:proc]
    @models = []
  end

  def models
    if parent.persisted?
      parent.send(association_name)
    else
      records.times do
        args = {assoc_name: @association_name, parent: @parent, proc: @proc}
        @models << SubForm.new(args)
      end

      @models
    end
  end

  def each(&block)
    @models.each do |form|
      block.call(form)
    end
  end
end