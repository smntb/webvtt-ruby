module WebVTT
  class Annotation
    attr_reader :references, :annotations, :text, :metadata

    ANNOTATION_REGEX = %r(<c\.\d+>[^<]+</c>).freeze
    METADATA_REGEX = /annotation set (\w+:\s.+)\n/i.freeze
    REFERENCES_REGEX = %r(<annotation ref="\d+">.+</annotation>\n).freeze

    def initialize(content)
      @content = content
      @metadata = {}
      @annotations = []

      parse_references
      parse_metadata
    end

    def parse_metadata
      @content.scan(METADATA_REGEX).each do |data|
        data = data[0].split(': ')
        @metadata[data[0].strip] = data[1].strip
      end
    end

    def parse_references
      @references = @content.scan(REFERENCES_REGEX).join("\n")
    end

    def parse(text)
      @text = text
      @annotations = extract_annotations
    end

    def extract_annotations
      @text.scan(ANNOTATION_REGEX).map do |annotation|
        text = sanitize(annotation)
        start_index = strip_tags(@text).index(text)
        end_index = start_index + text.length
        annotation_ref = parse_annotation_reference(annotation)

        { text: text, start: start_index, end: end_index, annotation: annotation_ref }
      end
    end

    def sanitize(text)
      text.gsub(%r((<c\.\d+>|</c>)), '')
    end

    def strip_tags(text)
      text.gsub(%r((<v>|</v>|<c\.\d+>|</c>)), '')
    end

    def parse_annotation_reference(annotation)
      ref_id = annotation.match(%r((?<=<c\.)\d+(?=>)))
      @references.match(%r(<annotation ref="#{ref_id}">(.+)<\/annotation>\n))[1]
    end
  end
end
