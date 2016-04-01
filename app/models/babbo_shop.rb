class BabboShop

  attr_reader :products, :premium_products, :basic_products, :receiver

  class << self
    attr_accessor :instance

    # Return the shared +ServerBackend+ instance.
    def get
      BabboShop.instance ||= BabboShop.new
    end
  end

  def initialize
    @iap_helper = IAPHelper.new(NSSet.setWithArray(ServerBackend.get.get_identifiers))

    load_product_informations
  end

  def load_product_informations
    @products = []
    @premium_products = []
    @basic_products = []

    @iap_helper.request_product_info do |success, products|
      products.each do |product|
        story = ShopProduct.new(product)
        @products << story
        if product.price != 0.00
          @premium_products << story
        else
          @basic_products << story
        end
      end

      @receiver.reload_data if @receiver
    end


  end

  def get_identifiers
    return @iap_helper.product_identifiers
  end

  def buy_product(identifier)

  end

  def get_premium_products
    return @premium_products
  end

  def get_basic_products
    return @basic_products
  end

  def get_all_products
    return @products
  end

  def register_for_updates (cl)
    @receiver = cl
  end

end