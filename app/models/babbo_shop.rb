class BabboShop

  attr_reader :products, :premium_products, :basic_products

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

      NSNotificationCenter.defaultCenter.postNotificationName('ShopBundleChanged',
                                                              object:nil)
    end
  end

  def get_identifiers
    return @iap_helper.products
  end

  def buy_product(identifier)
    product = @products.find{|product| product.productIdentifier == identifier}
    @iap_helper.buy_product(product)
  end

  def get_premium_products
    products = @premium_products.select{|product| product.not_installed?}
    return products
  end

  def get_basic_products
    products = @basic_products.select{|product| product.not_installed?}
    return products
  end

  def get_all_products
    #load_product_informations if @product.nil?
    return @products
  end

end