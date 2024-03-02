class ProductsController < ApplicationController
  def index
    @products = Product.order(id: :desc)
  end

  def product_list
    @first_page = 1
    @record_in_page = 5
    @last_page = (Product.count / @record_in_page).to_i
  
    sorting_order = params[:order].present? ? params[:order].to_sym : :asc
    @products = Product.order(name: sorting_order).paginate(page: params[:page], per_page: 5)
  end

  def new
    @product = Product.new 
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend('product_body', partial: 'products/product',
                                                    locals: { product: @product })
          ]
        end
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('modal', partial: 'products/new',
                                         locals: { product: @product })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update(product_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend('product_body', partial: 'products/product',
                                                    locals: { product: @product })
          ]
        end
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update('modal', partial: 'products/product',
                                         locals: { product: @product })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product = Product.destroy(params[:id])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("product_#{@product.id}")
        ]
      end
      format.html { redirect_to product_path, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end
end
