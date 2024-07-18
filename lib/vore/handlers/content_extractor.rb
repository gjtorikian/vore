# frozen_string_literal: true

module Vole
  module Handlers
    class ContentExtractor
      SELECTOR = Selma::Selector.new(match_element: "*", match_text_within: "title")

      attr_reader :title, :meta

      def initialize
        super
        @title = ""
        @meta = {}
        @within_title = false
      end

      def selector
        SELECTOR
      end

      def handle_element(element)
        if element.tag_name == "pre" || element.tag_name == "code" || element.tag_name == "script" || element.tag_name == "form"
          element.remove
        elsif element.tag_name == "title"
          @within_title = true
          element.remove
        elsif element.tag_name == "meta"
          return if element.attributes["name"].nil?

          @meta[element.attributes["name"]] = element.attributes["content"]
        else
          element.remove_and_keep_content
        end
      end

      def handle_text_chunk(text)
        if @within_title
          @within_title = false
          @title = text.to_s
        end
      end
    end
  end
end
