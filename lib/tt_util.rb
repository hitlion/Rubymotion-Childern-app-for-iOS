class TTUtil

  def self.unzip_file(file_url, toDestination: destination, withName: name)
    Dispatch::Queue.concurrent.sync do
      NSLog("Entpacke Daten von %@ ...", file_url)
      data = NSData.dataWithContentsOfURL(file_url)

      return if data.nil?

      file_name = file_url.lastPathComponent
      file_path = "#{NSTemporaryDirectory()}#{file_name}"

      data.writeToFile(file_path, atomically: true)
      data_path = destination.stringByAppendingPathComponent(name)

      SSZipArchive.unzipFileAtPath(file_path, toDestination: data_path)

      NSLog('Daten entpackt!')
    end
  end

  def self.isVersion(versionA, greaterThan: versionB)
    version_a = versionA.split('.')
    version_b = versionB.split('.')

    version_a  = version_a.collect {|i| i.to_i}
    version_b  = version_b.collect {|i| i.to_i}

    return nil unless version_a.length ==  version_b.length
    return nil unless version_a.length == 3
    return nil unless version_b.length == 3


    if version_a == version_b
      return false
    else
      version_a.each_with_index do |value, index|
        return true if value > version_b[index]
        return false if value < version_b[index]
      end
    end

  end
end