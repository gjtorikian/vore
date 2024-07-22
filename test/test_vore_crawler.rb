# frozen_string_literal: true

require "test_helper"

class TestVoreCrawler < Minitest::Test
  def test_it_can_crawl_a_real_site
    crawler = Vore::Crawler.new
    results = crawler.scrape_each_page("https://choosealicense.com") do |page|
      assert(page.title)
      assert(page.meta)
      assert(page.content)
      refute_equal(page.content, "")
      refute_includes(page.content, page.title)
    end

    assert_equal(32, results[:pages_visited])
  end if ENV["LIVE"] # Not making real requests by default

  def test_it_can_crawl_a_site_that_has_bad_encoding
    results = Vore::Crawler.new(options: { delay: 100 }).scrape_each_page("https://docs.github.com") do |page|
      assert(page.content)
      refute_equal(page.content, "")
    end

    assert_equal(0, results[:unprocessed_pages].length)
  end if ENV["LIVE"] # Not making real requests in CI

  def test_it_can_crawl_a_mocked_site
    crawler = Vore::Crawler.new
    results = []
    VCR.use_cassette("docs_github_com") do
      results = crawler.scrape_each_page("https://docs.github.com") do |page|
        assert(page.title)
        assert(page.meta)
        assert(page.content)
        refute_equal(page.content, "")
        refute_includes(page.content, page.title)
      end
    end

    assert_equal(5, results[:pages_visited])
  end if ENV["CI"]
end
