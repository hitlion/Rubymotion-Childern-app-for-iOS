# A global cache for storing and de-duplicating story assets.
#
# The cache works by collecting all existing story assets with one
# file for each unique asset. Assets are added to the cache by means
# of creating a hash of the orinigal files data und then creating a
# hardlink in the cache directory named after that hash.
#
# With this setup files with the same data will be hardlinked to the same
# file inside the cache (with duplicates removed and replaced by hardlinks).
#
# The cache can be purged to remove all contained files or simply compacted
# in which case all files that have no references in stories (and thus a
# hardlink count of 1) will be removed.
class AssetStore
  # subpath inside the cache directory
  CACHE_DIR = 'assets'

  def initialize
    @cache_path = begin
      File.join(Dir.system_path(:caches), CACHE_DIR)
    end

    if Dir.exist? @cache_path
      @valid = true
    else
      # NOTE: Dir#mkdir could be used here but it has no equivalent
      #   to 'withIntermediateDirectories: true'.
      @valid = Dir.mkdirs(@cache_path)
    end
  end

  # Check if the cache is valid and useable.
  def valid?
    @valid
  end

  # Remove *all* cached resources and empty out the cache directory.
  # @return [Boolean] If the cache was purged successfully.
  def purge!
    return false unless valid?

    Dir.foreach(@cache_path) do |entry|
      path = File.join(@cache_path, entry)
      File.unlink(path) if File.file? path
    end

    true
  rescue SystemCallError
    false
  end

  # Compact the cache by removing resources which are no longer referenced.
  #
  # Internally this works by checking the hardlinke count of all files inside
  # the cache directory and removing all with a link count less than 2.
  def compact!
    return false unless valid?

    Dir.foreach(@cache_path) do |entry|
      path = File.join(@cache_path, entry)
      File.unlink(path) if File.stat(path).nlink < 2
    end

    true
  rescue SystemCallError
    false
  end

  # Check if the cache contains the resource at +path+.
  #
  # If found the original file at +path+ will be replaced my a hardlink
  # to the cached resource.
  # If not found a hardlink for the file at +path+ will be created in
  # the cache for future use.
  #
  # @return [Boolean] If the resource was successfully cached.
  def cache_resource( path )
    resource_hash = compute_hash(path)
    return true if find_resource(resource_hash)

    copy_resource(resource_hash, path)
  end

  private

  # Compute a unique hash of the file contents at +path+ and return it
  # in string form.
  # @return [String] The unique hash for +path+'s data.
  #   If +path+ could net be read this will be an empty string.
  def compute_hash( path )
    NSData.sha1FromContentsOfFile(path)
  end

  # Locate a resource file given it's resource hash.
  #
  # @return [String] The valid cache path including the files extension.
  # @return [NilClass] If no matching resource can be found.
  def find_resource( resource_hash )
    return nil unless valid?

    Dir.glob(File.join(@cache_path, "#{resource_hash}.*")).first
  end

  # Copy the file at +path+ into the cache using +resource_hash+
  #   as the storage id.
  #
  # Internally the cache will be checked for an existing file matching
  # +resource_hash+. If found this file will first be unlinked.
  # Following this check a hardlink between the cache file and the original
  # located at +path+ is created.
  #
  # @param resource_hash [String] A unique key identifiyng the resource.
  # @param path [String] The file system path to the original file.
  # @return [Boolean] +true+ If no error occured.
  # @return [Boolean] +false+ If the file could not be cached.
  def copy_resource( resource_hash, path )
    # NOTE: the whole caching assumes that two files with the same
    #   resource hash contain the same data.
    cache_path = find_resource(resource_hash)
    unless cache_path.nil?
      File.unlink(cache_path)
    end

    cache_path = File.join(@cache_path, "#{resource_hash}#{File.extname(path)}")
    File.link(path, cache_path)

    true
  rescue SystemCallError
    false
  end
end

