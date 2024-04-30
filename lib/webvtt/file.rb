module WebVTT
  class File < Blob
    attr_reader :path, :filename

    def initialize(webvtt_file)
      if !::File.exists?(webvtt_file)
        raise InputError, "WebVTT file not found"
      end

      @path = webvtt_file
      @filename = ::File.basename(@path)
      super(::File.read(webvtt_file))
    end

    def save(output=nil)
      output ||= @path.gsub(".srt", ".vtt")

      ::File.open(output, "w") do |f|
        f.write(to_webvtt)
      end
      return output
    end
  end
end
