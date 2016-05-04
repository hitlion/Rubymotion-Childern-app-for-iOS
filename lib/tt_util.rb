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

end