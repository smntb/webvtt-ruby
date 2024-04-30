module WebVTT
  def self.read(file)
    File.new(file)
  end

  def self.from_blob(content)
    Blob.new(content)
  end

  def self.convert_from_srt(srt_file, output=nil)
    if !::File.exists?(srt_file)
      raise InputError, "SRT file not found"
    end

    srt = ::File.read(srt_file)
    output ||= srt_file.gsub(".srt", ".vtt")

    # normalize timestamps in srt
    srt.gsub!(/(:|^)(\d)(,|:)/, '\10\2\3')
    # convert timestamps and save the file
    srt.gsub!(/([0-9]{2}:[0-9]{2}:[0-9]{2})([,])([0-9]{3})/, '\1.\3')
    # normalize new line character
    srt.gsub!("\r\n", "\n")

    srt = "WEBVTT\n\n#{srt}".strip
    ::File.open(output, "w") {|f| f.write(srt)}

    return File.new(output)
  end
end
