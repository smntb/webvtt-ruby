module WebVTT
  class Annotation
    attr_reader :references, :annotations, :text, :title, :creator, :date

    ANNOTATION_REGEX = %r(<c\.\d+>[^<]+</c>).freeze
    REFERENCES_REGEX = %r(<annotation ref="\d+">.+</annotation>\n).freeze

    def initialize(content)
      @content = content
      parse_metadata
      @references = parse_references
      @annotations = []
    end

    def parse_metadata
      @title = extract_metadata(/annotation set title:\s(.+)\n/i)
      @creator = extract_metadata(/annotation set creator:\s(.+)\n/i)
      @date = extract_metadata(/annotation set date:\s(.+)\n/i)
    end

    def extract_metadata(regex)
      match = @content.match(regex)
      match[1] if match
    end

    def parse_references
      @content.scan(REFERENCES_REGEX).join("\n")
    end

    def parse(text)
      @text = text
      @annotations = extract_annotations
    end

    def extract_annotations
      @text.scan(ANNOTATION_REGEX).map do |annotation|
        target = sanitize(annotation)
        start_index = sanitize_speaker(@text).index(annotation)
        end_index = start_index + target.length
        annotation_ref = parse_annotation_reference(annotation)

        { target: target, start: start_index, end: end_index, annotation: annotation_ref }
      end
    end

    def sanitize(text)
      text.gsub(%r((<c\.\d+>|</c>)), '')
    end

    def sanitize_speaker(text)
      text.gsub(%r((<v>|</v>)), '')
    end

    def parse_annotation_reference(annotation)
      ref_id = annotation.match(%r((?<=<c\.)\d+(?=>)))
      @references.match(%r(<annotation ref="#{ref_id}">(.+)<\/annotation>\n))[1]
    end
  end
end
