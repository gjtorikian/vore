# frozen_string_literal: true

require "test_helper"

class TestVoreCrawler < Minitest::Test
  def test_it_can_crawl_a_site
    crawler = Vore::Crawler.new
    crawler.scrape_each_page("https://choosealicense.com") do |page|
      assert(page.title)
      assert(page.meta)
      assert(page.content)
      refute_includes(page.content, page.title)
    end
  end

  def test_it_can_crawl_a_site_that_has_bad_encoding
    Vore::Crawler.new.scrape_each_page("https://docs.github.com") do |page|
      assert(page.content)
    end
  end
end
