module OverlayViewModuleNew

  attr_reader :story, :bundle, :type

  CellIdentifier = 'Cell'

  def initWithFrame( frame)
   super(frame).tap do

      register_for_shop

      if(device.iphone?)
        rmq(self).stylesheet = OverlayViewModuleIPhoneStylesheet
      else
        rmq(self).stylesheet = OverlayViewModuleStylesheet
      end

      rmq(self).apply_style(:root)

      append(UIView, :grey_layer)

      overlay = append!(UIView, :background_layer)

      top    = overlay.append!(UIView, :top)
      bottom = overlay.append!(UIView, :bottom)

      @image_box = top.append!(UIImageView, :image_box)
      @title_label = top.append(UILabel, :title_label).get

      top.append(UIButton,    :cancel_button).on(:tap) do |sender|
        cancel_button_pressed
      end

      @date_label = top.append(UILabel, :date_label).get
      @left_button = top.append(UIButton, :left_button).get
      @left_button.on(:tap) do
        left_button_pressed
      end

      @right_button = top.append(UIButton, :right_button).get
      @right_button.on(:tap) do
        right_button_pressed
      end

      @progress_view = top.append(UIProgressView, :progress_view).get
      @status_label = top.append(UILabel, :status_label).get

      @top_button_line = top_button_line = top.append(UIView, :top_button_line).get

      @top_button_1 = top_button_line.append(UIButton, :top_button_1).get
      @top_button_1.on(:tap) do
        top_button_1_pressed
      end

      @top_button_2 = top_button_line.append(UIButton, :top_button_2).get
      @top_button_2.on(:tap) do
        top_button_2_pressed
      end

      @top_button_3 = top_button_line.append(UIButton, :top_button_3).get
      @top_button_3.on(:tap) do
        top_button_3_pressed
      end

      top.append(UIView, :line)

      bottom_button_line = bottom.append(UIView, :bottom_button_line).get
      @bottom_button_1 = bottom_button_line.append(UIButton, :bottom_button_1).get
      @bottom_button_1.on(:tap) do
        bottom_button_line_pressed(@bottom_button_1, tag: 0)
      end

      @bottom_button_line_selected = @bottom_button_1

      @bottom_button_2 = bottom_button_line.append(UIButton, :bottom_button_2).get
      @bottom_button_2.on(:tap) do
        bottom_button_line_pressed(@bottom_button_2, tag: 1)
      end

      @text_view = bottom.append(UITextView, :description_box).get

      layout = UICollectionViewFlowLayout.alloc.init
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal

      frame = CGRectMake(0.025 * bottom.frame.size.width, 0.2 * bottom.frame.size.height,
                         0.95  * bottom.frame.size.width, 0.7 * bottom.frame.size.height )

      @screenshot_collection_view = UICollectionView.alloc.initWithFrame(frame, collectionViewLayout: layout)
      @screenshot_collection_view.dataSource = self
      @screenshot_collection_view.delegate = self

      height = @screenshot_collection_view.frame.size.height
      width  = (4 * height) / 3
      size = CGSizeMake(width, height)

      layout.itemSize = size

      @screenshot_collection_view.registerClass(OverlayScreenshotCell, forCellWithReuseIdentifier: CellIdentifier)
      @screenshot_collection_view.backgroundColor = UIColor.clearColor
      @screenshot_collection_view.hidden = true

      bottom.addSubview(@screenshot_collection_view)
   end
  end

  def show_overlay_type(type, data: story)
    new_story  = nil
    new_bundle = nil

    if(story.class == StoryBundle)
      new_story  = story.document
      new_bundle = story
    else
      new_story = story
    end

    NSLog(new_story.productIdentifier)
    NSLog(@story.productIdentifier) unless @story.nil?

    if(@story.nil?)
      @story = new_story unless new_story.nil?
      @bundle = new_bundle unless new_bundle.nil?
      @type = type
      NSLog(@story.productIdentifier)
      relayout_with_type
    end

    if(new_story.productIdentifier != @story.productIdentifier || type != @type )
      @story = new_story unless new_story.nil?
      @bundle = new_bundle unless new_bundle.nil?
      @type = type
      relayout_with_type
    end

    self.hidden = false
  end

  def hide
    self.hidden = true
  end

  private

  def register_for_shop

    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadWaitingNotification:',
                                                   name: 'IAPDownloadWaiting',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadActiveNotification:',
                                                   name: 'IAPDownloadActive',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadFinishedNotification:',
                                                   name: 'IAPDownloadFinished',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadFailedNotification:',
                                                   name: 'IAPDownloadFailed',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadCancelledNotification:',
                                                   name: 'IAPDownloadCancelled',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedDownloadPauseNotification:',
                                                   name: 'IAPDownloadPause',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedIAPTransactionCancelled:',
                                                   name: 'IAPTransactionCancelled',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedIAPTransactionSucces:',
                                                   name: 'IAPTransactionSucces',
                                                   object: nil)
    NSNotificationCenter.defaultCenter.addObserver(WeakRef.new(self),
                                                   selector: 'receivedIAPTransactionFailed:',
                                                   name: 'IAPTransactionFailed',
                                                   object: nil)
  end

  def receivedIAPTransactionCancelled(notification)

  end

  def receivedIAPTransactionSuccess(notification)
    if notification[:transaction].downloads

    end
    @left_button.hidden = true
  end

  def receivedIAPTransactionFailed(notification)

  end

  def receivedDownloadWaitingNotification(notification)
    @status_label.text = 'Warte auf Download'
    @progress_view.progress = 0.0
  end

  def receivedDownloadActiveNotification(notification)
    return if @story.nil?
    #@right_button.hidden = false
    #NSLog(notification.userInfo[:download].progress.to_s)
    if(notification.userInfo[:download].contentIdentifier == @story.productIdentifier)
      @progress_view.progress = notification.userInfo[:download].progress
      @status_label.hidden = false
      @progress_view.hidden = false
      @left_button.hidden = true
      @status_label.text = 'Download läuft'
      @story.downloading = true
    end

  end

  def receivedDownloadFinishedNotification(notification)
    return if @story.nil?
    if(notification.userInfo[:download].contentIdentifier == @story.productIdentifier)
      @status_label.text = 'Download Beendet'
      @progress_view.progress = 1.0
      @left_button.hidden = false
      @story.downloading = false
      hide
    end
  end

  def receivedDownloadFailedNotification(notification)
    @status_label.text = 'Download fehlgeschlagen'
    @progress_view.progress = 0.00

    app.alert(title: "Download fehlgeschlagen!", message: "Probieren sie es erneut.", actions: ['OK']) do |button_tag|
      case button_tag
        when 'OK'
          @right_button.hidden = true
          @left_button.hidden = false
      end
    end

    if(notification.userInfo[:download].contentIdentifier == @story.productIdentifier)
      @story.downloading = false
    end

  end

  def receivedDownloadCancelledNotification(notification)
    @status_label.text = 'Download abgebrochen'
    @progress_view.progress = 0.0

    app.alert(title: "Download abbgebrochen!", message: "Sie haben den Download abgebrochen.", actions: ['OK']) do |button_tag|
      case button_tag
        when 'OK'
          @right_button.hidden = true
          @left_button.hidden = false
      end
    end

    if(notification.userInfo[:download].contentIdentifier == @story.productIdentifier)
      @story.downloading = false
    end
  end

  def receivedDownloadPauseNotification(notification)
    @status_label.text = 'Download pausiert'
    @progress_view.progress = notification.object.progress
  end

  def relayout_with_type
    if(@type == :menu_standard)
      @image_box.image = UIImage.imageWithData(@bundle.asset_data(@story.thumbnail))
      @title_label.text = @story.set_name
      @date_label.hidden = false
      @date_label.text = Time.at(NSDate.dateWithNaturalLanguageString(@story.timestamp)).strftime("%d. %B %Y").to_s
      @left_button.setTitle('Starten', forState: UIControlStateNormal)
      @left_button.hidden = false
      @right_button.hidden = true
      @top_button_line.hidden = false
      @progress_view.hidden = true
      @status_label.hidden = true
      @top_button_1.setTitle('Bearbeiten', forState: UIControlStateNormal)
      @top_button_2.setTitle('Neu', forState: UIControlStateNormal)
      @top_button_3.setTitle('Löschen', forState: UIControlStateNormal)
    elsif (@type == :shop_premium)
      @image_box.image = @story.thumbnail
      @title_label.text = @story.set_name
      @date_label.hidden = true
      @progress_view.hidden = true
      @status_label.hidden = true
      label_text = "Kaufen, #{story.price} €"
      @left_button.setTitle(label_text, forState: UIControlStateNormal)
      @left_button.hidden = @story.downloading
      @right_button.hidden = true
      @right_button.setTitle('Abbrechen', forState: UIControlStateNormal)
      @top_button_line.hidden = true
    elsif (@type == :shop_basic)
      @image_box.image = @story.thumbnail
      @title_label.text = @story.set_name
      @date_label.hidden = true
      @progress_view.hidden = true
      @status_label.hidden = true
      @left_button.setTitle('Download', forState: UIControlStateNormal)
      @left_button.hidden = @story.downloading
      @right_button.hidden = true
      @right_button.setTitle('Abbrechen', forState: UIControlStateNormal)
      @top_button_line.hidden = true
    end

    @text_view.text = @story.description
    @bottom_button_1.setTitle('Beschreibung', forState: UIControlStateNormal)
    @bottom_button_2.setTitle('Bilder', forState: UIControlStateNormal)

    @screenshots = @story.screenshots
    @screenshot_collection_view.reloadData
  end

  def bottom_button_line_pressed(element, tag: tag)
    return if @bottom_button_line_selected == element

    if(tag == 0)
      image1 = rmq.image.resource('button_bg_left_grey.png')
      image2 = rmq.image.resource('button_bg_right_white.png')
    elsif (tag == 1)
      image1 = rmq.image.resource('button_bg_right_grey.png')
      image2 = rmq.image.resource('button_bg_left_white.png')
    end

    element.setBackgroundImage(image1, forState:UIControlStateNormal)
    element.setTitleColor(UIColor.whiteColor, forState: UIControlStateNormal)
    element.setTitleColor(UIColor.blackColor, forState: UIControlStateHighlighted)

    @bottom_button_line_selected.setBackgroundImage(image2, forState:UIControlStateNormal)
    @bottom_button_line_selected.setTitleColor(UIColor.blackColor, forState: UIControlStateNormal)
    @bottom_button_line_selected.setTitleColor(UIColor.whiteColor, forState: UIControlStateHighlighted)

    @bottom_button_line_selected = element

    show_description    if tag == 0
    show_screenshoots   if tag == 1
  end

  def left_button_pressed
    if (@type == :menu_standard)
      StartScreen.next_story = @bundle
      StartScreen.next_screen = :story_player
      StartScreen.last_screen = :parent_menu
      rmq.screen.open_root_screen(StartScreen)
    elsif(@type == :shop_premium || @type == :shop_basic)
      @left_button.hidden = true
      BabboShop.get.buy_product(@story.productIdentifier)
    end
  end

  def right_button_pressed
    if (@type == :shop_premium || @type == :shop_basic)
      NSNotificationCenter.defaultCenter.postNotificationName('IAPDownloadCanceledForced',
                                                              object:nil,
                                                              userInfo: {
                                                                  :download => download,
                                                              })
    end
  end

  def top_button_1_pressed
    if (@type == :menu_standard)
      edit_story
    end
  end

  def top_button_2_pressed
    if (@type == :menu_standard)
      new_story
    end
  end

  def top_button_3_pressed
    if (@type == :menu_standard)
      remove_story
    end
  end

  def show_screenshoots
    @text_view.hidden = true
    @screenshot_collection_view.hidden = false
  end

  def show_description
    @text_view.hidden = false
    @screenshot_collection_view.hidden = true
  end

  def cancel_button_pressed
    self.hidden = true
  end

  def edit_story
    if @bundle.ruleset.rules.empty?
      app.alert(title: 'Entschuldigung',
                message: 'Diese Story kann nicht bearbeitet werden.')
    else
      lp @bundle.document.status

      if(@bundle.document.status == :V1)
        app.alert(title: 'Entschuldigung, das Original darf nicht beabeitet werden!',
                  message: 'Ihr müsst zunächst eine neue Story aus diesem Original erstellen.')
      else
        StartScreen.next_story = @bundle
        StartScreen.next_screen = :story_editor
        StartScreen.last_screen = :parent_menu
        StartScreen.editor_mode = :edit
        rmq.screen.open_root_screen(StartScreen)
      end
    end
  end

  def remove_story
    app.alert(title: "Achtung!", message: "Wollen sie diese Story wirklich löschen", actions: ['JA', 'NEIN']) do |button_tag|
      case button_tag
        when 'JA'
          NSFileManager.defaultManager.removeItemAtPath(@bundle.path, error:nil)
          StoryBundle.delete_story(@bundle)
          hide
        when 'NEIN'
      end
    end
  end

  def new_story
    if @bundle.ruleset.rules.empty?
      app.alert(title: 'Entschuldigung',
                message: 'Diese Story kann nicht bearbeitet werden.')
    else
      StartScreen.next_story = @bundle
      StartScreen.next_screen = :story_editor
      StartScreen.last_screen = :parent_menu
      StartScreen.editor_mode = :new
      rmq.screen.open_root_screen(StartScreen)
    end
  end

  # UICollectionView Instance Methods
  def collectionView(view, numberOfItemsInSection:section)

    if(view == @screenshot_collection_view)
      return @screenshots.length unless @screenshots.nil?
    end

    return 0
  end

  def collectionView(view, cellForItemAtIndexPath:path)
    cell = view.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: path)

    if(view == @screenshot_collection_view)
      screenshot = @screenshots[path.row] unless @screenshots.nil?
      cell.delegate = WeakRef.new(self)
      cell.make_cell(screenshot)
    end

    cell
  end
end