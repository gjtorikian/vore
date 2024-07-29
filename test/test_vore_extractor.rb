# frozen_string_literal: true

class TestVoreCrawler < Minitest::Test
  def setup
    @default
  end

  def test_it_can_parse_meta_tags
    file = fixture_file_path("content.html")

    crawler = Vore::Crawler.new
    crawler.process_file(file) do |page|
      refute_empty(page.title)
      refute_empty(page.meta)
    end
  end
end
