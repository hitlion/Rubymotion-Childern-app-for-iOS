# A few handy extensions to the +Dir+ class to make working with
# iOS native paths a little more Ruby like.
class Dir
  class << self
    # Return the path to +full_name+ inside the applications main bundle.
    #
    # @param [String] full_name The full (relative) path to the resource
    # @return [String] The absolute path to the resource in the apps bundle.
    #   or +nil+ if no such file exists
    def resource( full_name )
      name = full_name[/^(.*)\..*$/, 1]
      type = full_name[/^.*\.(.*)$/, 1]
      NSBundle.mainBundle.pathForResource(name, ofType: type)
    end

    # Shorthand to access some common iOS paths in a more Ruby like fashion.
    # +type+ should be one of:
    #
    # - :documents => NSDocumentDirectory
    # - :autosaved_information => NSAutosavedInformationDirectory
    # - :caches => NSCachesDirectory
    # - :application_support => NSApplicationSupportdirectory
    # - :downloads => NSDownloadsDirectory
    # - :item_replacement => NSItemReplacementDirectory
    #
    # @param [Symbol] type The requested system path key.
    # @return [String] The absolute path to the system directory or +nil+.
    def system_path( type )
      paths = {
        :documents             => NSDocumentDirectory,
        :autosaved_information => NSAutosavedInformationDirectory,
        :caches                => NSCachesDirectory,
        :application_support   => NSApplicationSupportDirectory,
        :downloads             => NSDownloadsDirectory,
        :item_replacement      => NSItemReplacementDirectory
      }
      return nil unless paths.has_key? type

      url = NSFileManager.defaultManager.URLsForDirectory(paths[type],
                                                          inDomains: NSUserDomainMask).first
      return nil if url.nil?

      url.fileSystemRepresentation
    end

    # Like {Dir#mkdir} but also create all intermediate paths.
    # This method will not fail if the path exists.
    #
    # @param [String] path The path to be created.
    # @return [Boolean] +true+ if the path was created, otherwise +false+
    def mkdirs( path )
      NSFileManager.defaultManager.createDirectoryAtPath(path,
                                                         withIntermediateDirectories: true,
                                                         attributes: nil,
                                                         error: nil)
    end
  end
end
