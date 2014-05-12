require "form_object"

class ProductForm < FormObject::Base
  attributes :title, :price, :units, :description

end