module WebVTT
  class Annotation
    attr_reader :references, :annotations, :text, :metadata

    ANNOTATION_REGEX = %r(<c\.\d+>[^<]+</c>)
    METADATA_REGEX = /annotation set (\w+:\s.+)\n/i
    REFERENCES_REGEX = %r(<annotation ref="\d+" [^>]*>.*?</annotation>\n?)

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
        annotation_data = parse_annotation_reference(annotation)

        {
          text: text,
          start: start_index,
          end: end_index,
          annotation: annotation_data[:content] || annotation_data,
          attributes: annotation_data[:attributes] || {}
        }
      end
    end

    def sanitize(text)
      text.gsub(%r((<c\.\d+>|</c>)), '')
    end

    def strip_tags(text)
      text.gsub(%r((<v>|</v>|<c\.\d+>|</c>)), '')
    end

    def parse_annotation_reference(annotation)
      ref_id = annotation.match(/(?<=<c\.)\d+(?=>)/)
      annotation_match = @references.match(%r(<annotation ref="#{ref_id}"[^>]*>(.*?)<\/annotation>))
      return {} unless annotation_match

      # Extract the content inside the annotation tags
      content = annotation_match[1]

      # Extract all attributes from the annotation tag
      attributes = parse_annotation_attributes(ref_id)

      # Return both content and attributes
      { content: content, attributes: attributes }
    end

    def parse_annotation_attributes(ref_id)
      annotation_match = @references.match(/<annotation ref="#{ref_id}"([^>]*)>/)
      return {} unless annotation_match

      attributes_string = annotation_match[1]
      attributes = {}

      # Parse key="value" pairs from the attributes string
      attributes_string.scan(/(\w+)="([^"]*)"/) do |key, value|
        attributes[key] = value
      end

      attributes
    end
  end
end
