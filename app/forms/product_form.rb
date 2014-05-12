require "form_object"

class ProductForm < FormObject::Base
  attributes :title, :price

end