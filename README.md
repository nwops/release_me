# ReleaseMe

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'release_me'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install release_me

## Usage

### Gitlab and Gitlab CI
In gitlab you can create a task similar to the following.

```
bump_and_tag:
  type: release
  when: manual
  tags:
    - ruby2.2
  only:
    - master@above_on/above
  script:
    - bundle install
    - bundle exec bump_and_tag

write_checksum:
  type: release
  when: manual
  tags:
    - ruby2.2
  only:
    - master@nwops/release_me
  script:
    - bundle install
    - bundle exec bump_and_tag

```

### Local Release_me config

```
file_relative_path: 'lib/release_me/version.rb'
version_field: 'VERSION'
version_type: 'semver'
adapter_name: 'custom'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/release_me. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

