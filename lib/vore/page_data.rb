# frozen_string_literal: true

module Vore
  class PageData
    attr_reader :title, :meta, :content, :path

    def initialize(title:, meta:, content:, path:)
      @title = title
      @meta = meta
      @content = content
      @path = path
    end
  end
end
