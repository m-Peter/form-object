class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @product_form = ProductForm.new(@product)
  end

  # GET /products/1/edit
  def edit
    @product_form = ProductForm.new(@product)
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new
    @product_form = ProductForm.new(@product)

    respond_to do |format|
      if @product_form.save(product_params)
        format.html { redirect_to @product_form, notice: 'Product was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    @product_form = ProductForm.new(@product)

    respond_to do |format|
      if @product_form.save(product_params)
        format.html { redirect_to @product_form, notice: 'Product was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :description, :price, :units)
    end
end
