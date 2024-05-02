module WebVTT
  class Blob
    attr_reader :header
    attr_accessor :cues
    attr_reader :annotation_set

    def initialize(content = nil)
      @cues = []

      if content
        parse(
          content.gsub("\r\n", "\n").gsub("\r", "\n") # normalizing new line character
        )
      else
        @header = 'WEBVTT'
      end
    end

    def to_webvtt
      [@header, @cues.map(&:to_webvtt)].flatten.join("\n\n")
    end

    def total_length
      @cues.last.end_in_sec
    end

    def actual_total_length
      @cues.last.end_in_sec - @cues.first.start_in_sec
    end

    def parse(content)
      # remove bom first
      content.gsub!("\uFEFF", '')

      cues = content.split(/\n\n+/)
      @annotation_set = Annotation.new(content)

      @header = cues.shift
      header_lines = @header.split("\n").map(&:strip)
      if (header_lines[0] =~ /^WEBVTT/).nil?
        raise MalformedFile, 'Not a valid WebVTT file'
      end

      @cues = []
      cues.each do |cue|
        cue_parsed = Cue.parse(cue.strip)
        unless cue_parsed.text.nil?
          @cues << parse_annotations(cue_parsed)
        end
      end
    end

    def parse_annotations(cue)
      annotation_point = @annotation_set.parse(cue.text)

      cue.annotations = annotation_point unless annotation_point.nil?
      cue.content = @annotation_set.sanitize(cue.content)
      cue.text = @annotation_set.sanitize(cue.text)

      cue
    end
  end
end
