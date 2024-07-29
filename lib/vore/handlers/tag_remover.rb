# frozen_string_literal: true

module Vore
  module Handlers
    class TagRemover
      SELECTOR = Selma::Selector.new(match_element: "*")

      def selector
        SELECTOR
      end

      UNNECESSARY_TAGS = [
        # Remove code elements
        "pre",

        # Remove unnecessary elements
        "head",

        "form",
        "style",
        "noscript",
        "script",
        "svg",

        # Remove unnecessary nav elements
        "header",
        "footer",
        "nav",
        "aside",
      ]

      CONTENT_TO_KEEP = [
        "html",
        "body",
      ]

      def handle_element(element)
        if UNNECESSARY_TAGS.include?(element.tag_name)
          element.remove
        elsif CONTENT_TO_KEEP.include?(element.tag_name)
          element.remove_and_keep_content
        end
      end
    end
  end
end
