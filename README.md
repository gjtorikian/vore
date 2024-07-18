# Vore

![Vore, by LewdBacon](https://github.com/user-attachments/assets/0923cc84-4cca-4d95-8a0e-4dad650525d2)

Vore quickly crawls websites and spits out text sans tags. It's written in Ruby and powered by Rust.

## Installation


Install the gem and add to the application's Gemfile by executing:

    $ bundle add vore

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install vore

## Usage

```ruby
    crawler = Vore::Crawler.new
    crawler.scrape_each_page("https://choosealicense.com") do |page|
      puts page
    end
```

Each `page` is simply every text node. The scraping is managed by [`spider-rs`](https://github.com/spider-rs/spider), so you know it's fast.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gjtorikian/vore.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
