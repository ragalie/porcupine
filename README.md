# Porcupine

Porcupine is a JRuby wrapper for Netflix's [Hystrix library](https://github.com/Netflix/Hystrix).
It simplifies instantiating HystrixCommands and throws Ruby exceptions for most things that can
go wrong (execution failures, timeouts, short circuits, no threads in the thread pool).

## Installation

Add this line to your application's Gemfile:

    gem 'porcupine'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install porcupine

## Usage

Instantiate a Porcupine object and give it a name, a group name (optional), a timeout (optional) and a block:

```ruby
porcupine = Porcupine.new("Sleeping Beauty", "Disney Characters", 10_000) { sleep(50) }
```

You can also provide a [Setter](https://github.com/Netflix/Hystrix/wiki/Configuration) directly:

```ruby
setter = com.netflix.hystrix.HystrixCommand::Setter.withGroupKey(com.netflix.hystrix.HystrixCommandGroupKey::Factory.asKey("Disney Characters"))
                                                   .andCommandKey(com.netflix.hystrix.HystrixCommandKey::Factory.asKey("Sleeping Beauty"))
porcupine = Porcupine.new(setter) { sleep(50) }
```

Then either you can request a result immediately:

```ruby
porcupine.execute
```

Or retrieve a Future and get the result later:

```ruby
future = porcupine.queue
future.get # Blocks on the result
```

Subscribing to an event is also supported:

```ruby
observer = porcupine.observe
observer.subscribe { puts "done!" } # Will puts "done!" when finished
```

If you provide an onError function, then the function will receive exceptions raised:

```ruby
observer = porcupine.observe
observer.subscribe("onNext" => lambda {}, "onError" => lambda {|exception| puts exception}) # Will puts any exception
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
