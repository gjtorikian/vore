# frozen_string_literal: true

require "test_helper"

class TestVoreCrawler < Minitest::Test
  def test_it_does_something_useful
    crawler = Vore::Crawler.new
    crawler.scrape_each_page("https://choosealicense.com") do |page|
      puts page
    end
  end
end
