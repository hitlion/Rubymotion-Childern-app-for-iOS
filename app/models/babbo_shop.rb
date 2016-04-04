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

    @iap_helper.cancelled = cancelled_transaction
    @iap_helper.success = transaction_successful
    @iap_helper.failed = transaction_failed

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
    return @iap_helper.products
  end

  def buy_product(identifier)
    product = @products.find{|product| product.productIdentifier == identifier}
    @iap_helper.buy_product(product)
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


  def cancelled_transaction
    lambda {
      NSLog('Transaction Cancelled.')
    }
  end

  def transaction_successful
    lambda {
      NSLog('Thank you for your purchase. Downloading catalog update!')
      # Do something here to provide the content to your user
    }
  end

  def transaction_failed
    lambda {
      NSLog('Download failed!')
      # Do something here to provide the content to your user
    }
  end
end