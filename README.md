# Queue It

[![Gem Version](https://badge.fury.io/rb/rails-queue-it.svg)](https://badge.fury.io/rb/queue-it)
[![CircleCI](https://circleci.com/gh/platanus/queue-it.svg?style=shield)](https://app.circleci.com/pipelines/github/platanus/queue-it)

This gem has been develope to manage recurrent processes that need someone (or something) responsable.
For example, imagine you have a recurrent task for a certain group of people like responding the chat of
your website. A recurrent queue would help you distribuit in a uniform way the workload of the people in the group.
This gem installs an engine in your rails app.

## Installation

Add to your Gemfile:

```ruby
gem "rails-queue-it"
```

```bash
bundle install
```

Then, run the installer:

```bash
rails generate queue_it:install
```

## Usage

For the purpose of this explanation we'll use the models `Task` and `User` to explain the workaround of this gem. Both models only have one attribute: `:name`.
### Models of the gem
This gem implements the models `QueueIt::Queue` and `QueueIt::Node`, each queue has polymorphic relation with a queable object (i.e. a `Task` instace) and each node has a polymorphic relation with a nodable object (i.e. the object queued).

### Before Starting
This gem uses [`ActiveRecord::Locking::Pessimistic `](https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html) so the behaviour with sqlite is not the same as with Postgres or MySql. Make sure you use one of the latters.
### Queable concern
Add the `QueueIt::Queable` concern to the model you want to have a queue. In this case we'll ilustrate this with the task model:
```ruby
class Task < ApplicationRecord
  include QueueIt::Queable
end
```

### Concern methods
With the `QueueIt::Queable` concern added to your model you'll have access to a group of methods to manage the queue's behaviour.
Note that in this version of the gem the model with the concern will have only one queue through a `has_one` relationship included in the concern.

#### Create a Queue
The method `find_or_create_queue!` present in the concern will return a new queue (in case it was not created) or the queue realated to the instance model.
```ruby
task = Task.create!(name: 'Example Task')
task_queue = task.find_or_create_queue!
```

#### Add a node to the Queue
The method `push_to_queue` will allow you to add a nodable in the first position of the queue or the last one depending on the `head_node` param.
```ruby
task = Task.create!(name: 'Example Task')
nodable = User.create!(name: 'Gabriel')
head_node = true
# add the user as the nodable object in the first node of the queue
task.push_to_queue(nodable, head_node)
```
Note that the second value (`head_node`) is optional with a default `true` value.

> It's not necessary to create the queue manually. The `push_to_queue` method will execute `find_or_create_queue!` before adding the node.

#### Get next nodable/node of the queue
To obtain the next nodable/node of the queue we've implemented the methods `get_next_in_queue` and `get_next_node_in_queue`. The first one calls the second one but instead of returning the node returns the nodable object.
First, let's add some nodes to the queue:
```ruby
task = Task.create!(name: 'Example')
task.push_to_queue(User.create!(name: 'Gabriel'))
task.push_to_queue(User.create!(name: 'Leandro'))
task.push_to_queue(User.create!(name: 'Raimundo'))
# Note that the order of the queue is now: [Raimundo's node, Leandro's node, Gabriel's node]
```
Now with the `get_next_in_queue` method we'll the obtain user with name `'Raimundo'` and the order of the queue will be updated.
```ruby
nodable = task.get_next_node_in_queue
nodable.name == 'Raimundo' # true
# the new order of the queue will be: [Leandro's node, Gabriel's node, Raimundo's node]
```
Now if we would of used `get_next_node_in_queue` instead of `get_next_in_queue` method we would of obtained the node containing the user with name `'Raimundo'` as nodable and the order of the queue would have been updated like before.
```ruby
node = task.get_next_in_queue
node.nodable.name == 'Raimundo' # true
# the new order of the queue will be: [Leandro's node, Gabriel's node, Raimundo's node]
```

#### Get nodable/node by custom attribute of the queue
With the methods presented above you could only get the first nodable/node and for some cases this isn't enough. To obtain the first nodable/node that has some attribute value we've implemented the methods `get_next_in_queue_by` and `get_next_node_in_queue_by`. Both methods receive first a `nodable_attribute` and second the nodable `attribute_value` so the methods return the first nodable/node that has the attribute with the searching value.
Let's use the same queue that we used before:

``` ruby
task = Task.create!(name: 'Example')
task.push_to_queue(User.create!(name: 'Gabriel'))
task.push_to_queue(User.create!(name: 'Leandro'))
task.push_to_queue(User.create!(name: 'Raimundo'))
# Note that the order of the queue is now: [Raimundo's node, Leandro's node, Gabriel's node]
```
We could now search for the second user using the attribute name 'name' and the attribute value 'Leandro' like this.
``` ruby
nodable = task.get_next_in_queue_by('name', 'Leandro')
nodable.name == 'Leandro'  # true
# the new order of the queue will now be: [Raimundo's node, Gabriel's node, Leandro's node]
```
Now if we would of used `get_next_node_in_queue_by` method intead of `get_next_in_queue_by` we would obtain the node containing the user with name `'Leandro'` as a nodable and the queue would of been updated aswell.
``` ruby
node = task.get_next_node_in_queue_by('name', 'Leandro')
node.nodable.name == 'Leandro'  # true
# the new order of the queue will now be: [Raimundo's node, Gabriel's node, Leandro's node]
```
**Note** that the methods return the first nodable/node that matches the attribute value. In case of a queue that has, for example, users with the same value you should prefer searching for another attribute like the `'id'`.


#### Formatted Queue
We included a method to obtain the queue formatted by an attribute/method. Note that the nodables will need to have the attribute or an implementation of the method called.
```ruby
# creation of the queue
task = Task.create!(name: 'Example')
task.push_to_queue(User.create!(name: 'Gabriel'))
task.push_to_queue(User.create!(name: 'Leandro'))
task.push_to_queue(User.create!(name: 'Raimundo'))
# The order of the queue is now: [Raimundo's node, Leandro's node, Gabriel's node]
response = task.formatted_queue('name')
response == ['Raimundo', 'Leandro', 'Gabriel'] # true
```

### Obtain the connected nodes of the queue
To obtain the nodes that are connected we have implemented a method `connected_nodes`. This method is used for testing but it could be used for some other reason.
```ruby
# creation of the queue
task = Task.create!(name: 'Example')
task.push_to_queue(User.create!(name: 'Gabriel'))
task.push_to_queue(User.create!(name: 'Leandro'))
task.push_to_queue(User.create!(name: 'Raimundo'))
task.connected_nodes == 3 # true
```

#### Delete all the nodes of the queue
With the method `delete_queue_nodes` you'll be able to clean the queue.
```ruby
task = Task.create!(name: 'Example')
task.push_to_queue(User.create!(name: 'Gabriel'))
task.push_to_queue(User.create!(name: 'Leandro'))
task.push_to_queue(User.create!(name: 'Raimundo'))
# delete de queue nodes
task.delete_queue_nodes
task.queue.size? == 0 # true
```

#### Remove a nodable object
In case you need to remove all the nodes of a queue containing an specific nodable you can use the `remove_from_queue(nodable)` method.
```ruby
task = Task.create!(name: 'Example')
gabriel = User.create!(name: 'Gabriel')
leandro = User.create!(name: 'Leandro')
raimundo = User.create!(name: 'Raimundo')
task.push_to_queue(gabriel)
task.push_to_queue(leandro)
task.push_to_queue(raimundo)
task.push_to_queue(leandro)
# Now we have a queue that look's like this:
# [Leandro's node, Raimundo's node, Leandro's node, Gabriel's node]
task.remove_from_queue(leandro)
# The queue will now look like this: [Raimundo's node, Gabriel's node]
```

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
