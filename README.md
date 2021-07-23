# Queue It

[![Gem Version](https://badge.fury.io/rb/queue_it.svg)](https://badge.fury.io/rb/queue_it)
[![CircleCI](https://circleci.com/gh/platanus/queue_it.svg?style=shield)](https://app.circleci.com/pipelines/github/platanus/queue_it)

TODO

## Installation

Add to your Gemfile:

```ruby
gem "queue_it"
```

```bash
bundle install
```

Then, run the installer:

```bash
rails generate queue_it:install
```

## Usage

TODO

## Development

### Models and migrations

- Create dummy app models with development and testing purposes inside the dummy app `spec/dummy`:

  `bin/rails g model user`

  The `User` model will be created in `spec/dummy/app/models`.
  The `user_spec.rb` file needs to be deleted, but it is a good idea to leave the factory.

- Create engine related models inside the engine's root path '/':

  `bin/rails g model job`

  The `EngineName::Job` model will be created in `app/models/engine_name`.
  A factory will be added to `engine_name/spec/factories/engine_name/jobs.rb`, you must to add the `class` option manually.

  ```ruby
  FactoryBot.define do
    factory :job, class: "EngineName::Job" do
      # ...
    end
  end
  ```

- While developing the engine run migrations in the root path `bin/rails db:migrate`. This will apply the gem and dummy app migrations too.
- When using in a project, the engine migrations must be copied to it. This can be done by running: `bin/rails engine_name:install:migrations`

## Testing

To run the specs you need to execute, in the root path of the engine, the following command:

```bash
bundle exec guard
```

You need to put **all your tests** in the `/queue_it/spec` directory.

## Publishing

On master/main branch...

1. Change `VERSION` in `lib/queue_it/version.rb`.
2. Change `Unreleased` title to current version in `CHANGELOG.md`.
3. Run `bundle install`.
4. Commit new release. For example: `Releasing v0.1.0`.
5. Create tag. For example: `git tag v0.1.0`.
6. Push tag. For example: `git push origin v0.1.0`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

Thank you [contributors](https://github.com/platanus/queue_it/graphs/contributors)!

<img src="http://platan.us/gravatar_with_text.png" alt="Platanus" width="250"/>

Queue It is maintained by [platanus](http://platan.us).

## License

Queue It is © 2021 platanus, spa. It is free software and may be redistributed under the terms specified in the LICENSE file.
