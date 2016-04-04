module LoadingViewModule
  attr_accessor :progress_view
  attr_accessor :status_label

  def initWithFrame(frame)
    super.tap do
      rmq(self).stylesheet = LoadingViewModuleStylesheet
      rmq(self).apply_style(:root)

      @status_label = append!(UILabel, :status_label)
      @progress_view = append!(UIProgressView, :progress_view)

      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadWaitingNotification:", name: 'IAPDownloadWaiting', object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadActiveNotification:", name: 'IAPDownloadActive', object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFinishedNotification:", name: 'IAPDownloadFinished', object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadFailedNotification:", name: 'IAPDownloadFailed', object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadCancelledNotification:", name: 'IAPDownloadCancelled', object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedDownloadPauseNotification:", name: 'IAPDownloadPause', object: nil)
    end
  end

  def hide
    self.hidden = true
  end

  def show
    self.hidden = false
  end

  private

  def receivedDownloadWaitingNotification(notification)
    @status_label.text = 'Warte auf Download'
    @progress_view.progress = 0.0
  end

  def receivedDownloadActiveNotification(notification)

  end

  def receivedDownloadFinishedNotification(notification)
    statusLabel.text = 'Download beendet'
    progressView.progress = 1.0
  end

  def receivedDownloadFailedNotification(notification)

  end

  def receivedDownloadCancelledNotification(notification)

  end

  def receivedDownloadPauseNotification(notification)

  end


end