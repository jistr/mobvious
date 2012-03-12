# Mobvious

Mobvious detects whether your app / website is being accessed by a phone, or by a tablet,
or by a personal computer.

## Key Features

* **It's easy to get running.** Just a Rack middleware with almost no config. (See
  section Get Started below.)

* **It supports multiple strategies for detection.** If you don't like the default ones,
  you can easily write your own. (See section Detection Strategies below.)

* **Works with Rails, Sinatra, or whatever.** Does not depend on any application
  framework, uses just Rack.

* **[Documentation](http://rdoc.info/github/jistr/mobvious/frames).**
  

## Get Started

1.  **Include Mobvious in your Gemfile**: `gem 'mobvious'`

2.  **Tell your app to use Mobvious::Manager as Rack middleware.**  
    If you use Rails, simply add `config.middleware.use Mobvious::Manager` into your
    `config/application.rb` file.

3.  **Tell Mobvious which strategies it should use.**  
    A good place to put this code for Rails is an initializer – create a file
    `config/initializers/mobvious.rb` and put this in:

        Mobvious.configure do
          strategies = [ Mobvious::Strategies::MobileESP.new ]
        end

4.  **Done! From now on, device type is detected for each request.**  
    The information is
    in a Rack environment variable `env['mobvious.device_type']`, this variable will
    have a value of `:desktop` or `:mobile` depending on the device type that issued
    the request. In Rails, you can access it via `request.env['mobvious.device_type']`.

*This is just a very basic way of setting up Mobvious. If you want to detect
tablets separately, or let the user manually switch between interface versions of your
app, or do some funnier stuff, see sections Detection Process and Detection Strategies.*

## Detection Process

Mobvious uses an array of strategies to detect the device type.
Strategies are evaluated in order of appearance in the array. Each strategy may or
may not be successful in determining the device type. The result of the first successful
strategy is used. If no strategy is successful, the implicit device type is used
(defaults to `:desktop`, but this is configurable via `default_device_type` attribute
in the `configure` block).


## Detection Strategies

### MobileESP (User-Agent sniffing)

Selects the device type using information present in the User-Agent HTTP header.

Constructor takes a detection procedure.
Detection procedure decides what device type it should return based on the
information it can dig out of MobileESPConverted::UserAgentInfo instance.

There are two predefined detection procedures (and you can write your own):

*   `DEVICE_TYPES_MOBILE_DESKTOP` (this is the default)
    distinguishes between `:mobile` and `:desktop`. Tablets
    are reported as `:desktop`, because their screens are usually large enough to handle
    web interfaces meant for desktops.

*   `DEVICE_TYPES_MOBILE_TABLET_DESKTOP` distinguishes between `:mobile`, `:tablet`
    and `:desktop`.

### URL (URL pattern matching)

Selects the device type by matching a pattern against the request's URL (whole URL,
including protocol information).

Constructor takes a hash of rules in format `/regular_expression/ => :device_type`.

There is one predefined rule set:

*   `MOBILE_PATH_RULES` detects all URLs that begin with m. (e.g. `http://m.foo.com/`)
    as `:mobile`. Doesn't make assumption about other URLs (the detection process
    continues to the next strategy in order).

### Cookie (remembering user's manual choice)

This strategy is useful when you want the user to make a manual switch between interfaces
and you want all the interface versions running on the exact same URL.

Call this anywhere in your app:

        Mobvious.strategy('Cookie').set_device_type(:desktop)
        
… and Mobvious will report `:desktop` from now on for this particular user, regardless
of what is his/her real device type. Make sure to put the Cookie strategy high enough
in your strategies array (the first entry?) so it does not get overriden by some other
strategy.

Constructor takes array of allowed device types ("whitelist") that your
application supports. This is a countermeasure to users tampering with cookies. When
the device type read from cookie is not whitelisted, the strategy passes the detection
process to other strategies.

### Writing Your Own Strategy

It's super-easy. A valid Mobvious strategy is any object that responds to this method:

        def get_device_type(request)
          # some code here
        end

The request parameter is an object of type Rack::Request. The method must return either:

*   **a symbol** denoting the device type detected (strategy was successful), or
*   **nil** denoting that strategy was unsuccessful and detection process should continue
    with other strategies (or return the implicit device type).


Optionally, you can also implement this method:

        def response_callback(request, response)
          # some code here
        end

It gets called after a response is returned from the application and you can tweak the
response here if you want. The parameters are instances of Rack::Request
and Rack::Response, respectively. The method is not expected to return anything special.

---

***Everyone goes with the defaults anyway*** ![cereal guy](https://github.com/engina/9gagtension/raw/master/rages/cereal-guy.jpg)