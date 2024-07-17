# frozen_string_literal: true

module Vole
  module Handlers
    class ContentExtractor
      SELECTOR = Selma::Selector.new(match_element: "*")

      def selector
        SELECTOR
      end

      def handle_element(element)
        if element.tag_name == "pre" || element.tag_name == "code"
          element.remove
        else
          element.remove_and_keep_content
        end
      end
    end
  end
end
