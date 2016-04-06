# Slightly modified translation of this tutorial for RubyMotion
# http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
class IAPHelper
  attr_accessor :products_request, :completion_handler, :product_identifiers, :purchased_product_identifiers
  attr_accessor :cancelled, :success, :failed

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
    NSLog("completeTransaction...")

    self.provide_content(transaction.payment.productIdentifier)

    if(transaction.downloads)
      SKPaymentQueue.defaultQueue.startDownloads(transaction.downloads)
    end

    #SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def restoreTransaction(transaction)
    NSLog("restoreTransaction...")

    self.provide_content(transaction.originalTransaction.payment.productIdentifier)
    SKPaymentQueue.defaultQueue.finishTransaction(transaction)
  end

  def failedTransaction(transaction)
    NSLog("failedTransaction...")
    if transaction.error.code != SKErrorPaymentCancelled
      NSLog("Transaction error: %@", transaction.error.localizedDescription)
      @failed.call unless @failed.nil?
      #@completion_handler.call(false, nil) unless @completion_handler.nil?
      #@completion_handler = nil
    else
      @cancelled.call unless @cancelled.nil?
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
                                                                :download => download,
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
      NSLog("Quelle: %@", src)
      des = File.join(Dir.system_path(:documents), 'Bundles', bundle_name)
      NSLog("Ziel %@", des)
      @fileManager.copyItemAtPath(src, toPath: des, error: nil)
      new_bundles << des
    end

    new_bundles.each do |path|
      StoryBundle.add_new_bundle(path)
    end

    NSLog("loesche: %@", temp_folder)
    @fileManager.removeItemAtPath(temp_folder, error: nil)

    NSLog('4')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadFinished',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download,
                                                            })

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def waitingDownload(download)

    NSLog('Download waiting...')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadWaiting',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download,
                                                            })
  end

  def failedDownload(download)
    NSLog('Download failed...')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadFailed',
                                                            object:nil,
                                                            userInfo: {
                                                                :download => download,
                                                            })

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def cancelledDownload(download)

    NSLog('Download canceled...')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadCancelled',
                                                            object:nil,
                                                            userInfo: {:object => download})

    SKPaymentQueue.defaultQueue.finishTransaction(download.transaction)
  end

  def pauseDownload(download)

    NSLog('Download pause...')
    NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadPause',
                                                            object:nil,
                                                            userInfo: {:object => download})
  end

end