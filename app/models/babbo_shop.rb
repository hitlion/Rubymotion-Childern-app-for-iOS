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
    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'send_bundles_changed_notification:',
                                                   name: 'ShopBundleStatusChanged',
                                                   object: nil)

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'identifier_received:',
                                                   name: 'BackendUpdateIdentifier',
                                                   object: nil)

    BabboBackend.get.request_story_identifier(self)
  end

  def load_product_informations
    @products = []
    @premium_products = []
    @basic_products = []

    @iap_helper.request_product_info do |success, products|
      if(success)
        products.each do |product|
          story = ShopProduct.new(product)
          @products << story
          if product.price != 0.00
            @premium_products << story
          else
            @basic_products << story
          end
        end
        send_bundles_changed_notification (nil)
      else
        NSNotificationCenter.defaultCenter.postNotificationName('ShopRequestFailed',
                                                                object:nil,
                                                                userInfo: {
                                                                    :description => "Shop ist derzeit nicht erreichbar. Bitte prüfen Sie ihre Internetverbindung oder ihr Wlan!"
                                                                })
      end
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
    return nil unless @premium_products
    products = @premium_products.select{|product| product.not_installed?}
    return products
  end

  def get_basic_products
    return nil unless @basic_products
    products = @basic_products.select{|product| product.not_installed?}
    return products
  end

  def get_all_products
    return nil unless @products
    #load_product_informations if @product.nil?
    products =  @products
    return products
  end

  def identifier_received(notification)
    return unless (notification.userInfo[:sender] == self)

    update_identifier(notification.userInfo[:identifier])
  end

  def update_identifier(identifier)
    @iap_helper = nil
    @iap_helper = IAPHelper.new(NSSet.setWithArray(identifier))
    load_product_informations
  end

  def send_bundles_changed_notification (notification)
    NSNotificationCenter.defaultCenter.postNotificationName('ShopBundleUpdated',
                                                            object:nil)
  end


end