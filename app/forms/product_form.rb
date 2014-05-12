require "form_object"

class ProductForm < FormObject::Base
  attributes :title, :price, :units, :description
  validates :title, :price, :units, :description, presence: true
end