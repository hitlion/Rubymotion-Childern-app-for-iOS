class Shop

  def purchase_single_product(identifier)
    NSLog "Starting purchase process for #{identifier}."

    @iap_helper = IAPHelper.new(NSSet.setWithArray([identifier]))
    @iap_helper.cancelled = cancelled_transaction
    @iap_helper.success = transaction_successful
    @iap_helper.request_product_info do |success, products|
      if success && products.is_a?(Array) && products.count == 1
        NSLog("Price: %@", products.first.price)
        NSLog("downloadable: %@", products.first.downloadable)
        NSLog("downloadContentLengths: %@", products.first.downloadContentLengths)
        NSLog("downloadContentVersion: %@", products.first.downloadContentVersion)
        NSLog("localizedDescription: %@", products.first.localizedDescription)
        NSLog("localizedTitle: %@", products.first.localizedTitle)
        NSLog("productIdentifier: %@", products.first.productIdentifier)
        #@iap_helper.buy_product(products.first)
      else
        NSLog('There was a problem. Please try again later.')
      end
    end
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

end