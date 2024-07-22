# frozen_string_literal: true

require "minitest/mock"
require "net/http"

module Vore
  module TestHelper
    def run_command(website, **options)
      loop_times.times do |time|
        net_http = ::Minitest::Mock.new
        response = ::Minitest::Mock.new
        response.expect(:is_a?, true, [::Net::HTTPSuccess])

        # we need to trigger an HTTP call to pretend that we're making
        # an external request. this way, the gem hooks into VCR/Webmock
        net_http.expect(:get, response)
        html = content
        response.expect(:body, html)
        time_s = time.to_s
        uri = URI("#{website}/#{time_s}")
        Net::HTTP.get(uri)

        file = File.join(@output_dir, time_s)
        File.write("#{file}.html", html)
      end
    end

    def loop_times=(times)
      @loop_times = times
    end

    def loop_times
      @loop_times ||= 5
    end

    def meta_tag_count=(count)
      @meta_tag_count = count
    end

    def meta_tag_count
      @meta_tag_count ||= 5
    end

    def generate_word
      ("a".."z").to_a.sample(8).join
    end

    def generate_sentence
      Array.new((5..15).to_a.sample) { generate_word }.join(" ")
    end

    def generate_path
      Array.new((1..3).to_a.sample) { generate_word }.join("/")
    end

    def content
      html = "<!DOCTYPE html><html><head><title>#{generate_word}</title>"
      meta_tag_count.times do
        html += "<meta name=\"#{generate_word}\" content=\"#{generate_word}\" />"
      end

      html += "</head><body>"

      50.times do
        tagname = ["p", "h1", "h2", "h3", "h4", "h5", "h6"].sample
        html += "<#{tagname}>#{generate_sentence}</#{tagname}>"
      end

      html += "</body></html>"
      html
    end
  end

  Vore::Crawler.prepend(Vore::TestHelper)
end
