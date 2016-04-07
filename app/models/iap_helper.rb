# Slightly modified translation of this tutorial for RubyMotion
# http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
class IAPHelper
  attr_accessor :products_request, :completion_handler, :product_identifiers, :purchased_product_identifiers

  def initialize(product_identifiers)
    # Store product identifiers
    @product_identifiers = product_identifiers

    #Check for previously purchased products
    @purchased_product_identifiers = NSMutableSet.set
    @product_identifiers.each do |product_identifier|
      product_purchased = NSUserDefaults.standardUserDefaults.boolForKey(product_identifier)
      if product_purchased
        @purchased_product_identifiers.addObject(product_identifier)
        NSLog("Previously purchased: %@", product_identifier)
      else
        NSLog("Not purchased: %@", product_identifier)
      end
    end

    # Add self as transaction observer
    SKPaymentQueue.defaultQueue.addTransactionObserver(self)
  end

  def request_product_info(&block)
    NSLog('Requesting product information')
    @completion_handler = block

    @products_request = SKProductsRequest.alloc.initWithProductIdentifiers(@product_identifiers)
    @products_request.delegate = self
    @products_request.start
  end

  def product_purchased?(product_identifier)
    @purchased_product_identifiers.containsObject(product_identifier)
  end

  def buy_product(product)
    NSLog("Buying %@...", product.productIdentifier)

    payment = SKPayment.paymentWithProduct(product)
    SKPaymentQueue.defaultQueue.addPayment(payment)
  end

  #pragma mark - SKProductsRequestDelegate

  def productsRequest(request, didReceiveResponse:response)
    NSLog("Loaded list of products...")
    @products_request = nil

    sk_products = response.products
    sk_products.each do |sk_product|
      NSLog("Found product: %@ %@ %0.2", sk_product.productIdentifier, sk_product.localizedTitle, sk_product.price)
    end

    @completion_handler.call(true, sk_products)
    @completion_handler = nil
  end

  def request(request, didFailWithError:error)
    NSLog("Failed to load list of products.")
    @products_request = nil

    @completion_handler.call(false, nil)
    @completion_handler = nil
  end

  #pragma mark SKPaymentTransactionObserver

  def paymentQueue(queue, updatedTransactions:transactions)
    transactions.each do |transaction|
      case transaction.transactionState
        when SKPaymentTransactionStatePurchased
          self.completeTransaction(transaction)
        when SKPaymentTransactionStateFailed
          self.failedTransaction(transaction)
        when SKPaymentTransactionStateRestored
          self.restoreTransaction(transaction)
        else
      end
    end
  end

  def paymentQueue(queue, updatedDownloads: downloads)
    downloads.each do |download|

      case download.downloadState
        when SKDownloadStateActive
          activeDownload(download)
        when SKDownloadStateFinished
          finishedDownload(download)
        when SKDownloadStateWaiting
          waitingDownload(download)
        when SKDownloadStateFailed
          failedDownload(download)
        when SKDownlaodStateCanceled
          cancelledDownload(download)
        when SKDonwloadStatePause
          pauseDownload(download)
      end
    end
  end

  def completeTransaction(transaction)
    self.provide_content(transaction.payment.productIdentifier)

    if(transaction.downloads)
      SKPaymentQueue.defaultQueue.startDownloads(transaction.downloads)
    else
      SKPaymentQueue.defaultQueue.finishTransaction(transaction)
    end

    NSLog('Thank you for your purchase. Downloading startet now.')

    NSNotificationCenter.defaultCenter.postNotificationName('IAPTransactionSuccess',
                                                            object:nil,
                                                            userInfo: {
                                                                :transaction => transaction })
  end

  def restoreTransaction(transaction)
    self.provide_content(transaction.originalTransaction.payment.productIdentifier)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def failedTransaction(transaction)
    if transaction.error.code != SKErrorPaymentCancelled
      NSLog("Transaction failed with error: %@", transaction.error.localizedDescription)

      NSNotificationCenter.defaultCenter.postNotificationName('IAPTransactionFailed',
                                                              object:nil,
                                                              userInfo: {
                                                                  :transaction => transaction })

    else
      NSLog('Transaction Cancelled.')

      NSNotificationCenter.defaultCenter.postNotificationName('IAPTransactionCancelled',
                                                              object:nil,
                                                              userInfo: {
                                                                  :transaction => transaction })


    end
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def provide_content(product_identifier)
    @purchased_product_identifiers.addObject(product_identifier)
    NSUserDefaults.standardUserDefaults.setBool(true, forKey:product_identifier)
    NSUserDefaults.standardUserDefaults.synchronize

    @success.call unless @success.nil?
  end

  def restoreCompletedTransactions
    SKPaymentQueue.defaultQueue.restoreCompletedTransactions
  end

  private

  def activeDownload(download)
    NSLog('Download active...')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadActive',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download
                                                            })
  end

  def finishedDownload(download)
    NSLog("Downloaded %@",download.contentURL)
    @fileManager = NSFileManager.defaultManager()

    path = download.contentURL.fileSystemRepresentation
    temp_folder = File.join(Dir.system_path(:documents), 'Bundles', 'tempFolder')
    #copy and unpack to temp folder
    @fileManager.copyItemAtPath(path, toPath: temp_folder, error: nil)
    # delete downloaded file
    @fileManager.removeItemAtPath(path, error: nil)

    path = File.join(temp_folder, 'Contents')

    new_bundles = []

    Dir.glob("#{path}/*.zip").each do |zip_archive|
      NSLog(zip_archive)
      bundle_name = File.split(zip_archive).last
      NSLog(bundle_name)
      bundle_name = bundle_name.split('.zip').first
      NSLog(bundle_name)

      TTUtil.unzip_file(NSURL.fileURLWithPath(zip_archive), toDestination:temp_folder, withName:bundle_name)

      src = File.join(temp_folder, bundle_name, bundle_name)
      des = File.join(Dir.system_path(:documents), 'Bundles', bundle_name)
      @fileManager.copyItemAtPath(src, toPath: des, error: nil)
      new_bundles << des
    end

    new_bundles.each do |path|
      StoryBundle.add_new_bundle(path)
    end

    @fileManager.removeItemAtPath(temp_folder, error: nil)

    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadFinished',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download })

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def waitingDownload(download)
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadWaiting',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download })
  end

  def failedDownload(download)
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadFailed',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download })

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def cancelledDownload(download)
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadCancelled',
                                                            object:nil,
                                                            userInfo: {:object => download })

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def pauseDownload(download)
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadPause',
                                                            object:nil,
                                                            userInfo: {:object => download })
  end
end