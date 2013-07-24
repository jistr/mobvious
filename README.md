# Mobvious

Mobvious detects whether your app / website is being accessed by a phone, or by a tablet,
or by a personal computer. You can then use this information throughout your app. (E.g.
fork your front-end code with regard to device type. There is a
[plugin for Ruby on Rails](https://github.com/jistr/mobvious-rails) that helps you with this.)

## Key Features

* **It's easy to get running.** Just a Rack middleware with almost no config. (See
  section Get Started below.)

* **It supports multiple strategies for detection.** If you don't like the default ones,
  you can easily write your own. (See section Detection Strategies below.)

* **Works with Rails, Sinatra, or whatever.** Does not depend on any application
  framework, uses just Rack.

* **[Documentation](http://rdoc.info/github/jistr/mobvious/frames).**
  

## Get Started

1.  **Include Mobvious in your Gemfile**:

        gem 'mobvious'

2.  **Tell your app to use Mobvious::Manager as Rack middleware.**  
    If you use Rails, simply add this into your `config/application.rb`:

        config.middleware.use Mobvious::Manager

3.  **Tell Mobvious which strategies it should use.**  
    A good place for this code in Rails is an initializer – create
    `config/initializers/mobvious.rb` and use this config to begin with:

        Mobvious.configure do |config|
          config.strategies = [ Mobvious::Strategies::MobileESP.new(:mobile_tablet_desktop) ]
        end

4.  **Done! From now on, device type is detected for each request.**  
    The information is
    in a Rack environment variable `env['mobvious.device_type']`, this variable will
    have a value of `:desktop` or `:mobile` depending on the device type that issued
    the request. In Rails, you can access it via `request.env['mobvious.device_type']`
    or use [mobvious-rails](https://github.com/jistr/mobvious-rails)
    and access it simply via `device_type`.

*This is just a very basic way of setting up Mobvious. If you want to detect
tablets separately, or let the user manually switch between interface versions of your
app, or do some funnier stuff, see sections Detection Process, Example Configurations
and Detection Strategies.*

## Detection Process

Mobvious uses an array of strategies to detect the device type.
Strategies are evaluated in order of appearance in the array. Each strategy may or
may not be successful in determining the device type. The result of the first successful
strategy is used. If no strategy is successful, the implicit device type is used
(defaults to `:desktop`, but this is configurable via `default_device_type` attribute
in the `configure` block).


## Example Configurations

*   Detects only by User-Agent into mobile vs. tablet vs. desktop groups.

        Mobvious.configure do |config|
          config.strategies = [ Mobvious::Strategies::MobileESP.new(:mobile_tablet_desktop) ]
        end

*   Detects by User-Agent into mobile vs. tablet vs. desktop groups, but allows users
    to manually switch interface versions (Cookie strategy is used for this and it is
    the first one, so it has top precedence).

        Mobvious.configure do |config|
          config.strategies = [
            Mobvious::Strategies::Cookie.new([:mobile, :tablet, :desktop]),
            Mobvious::Strategies::MobileESP.new(:mobile_tablet_desktop)
          ]
        end

*   Detects by URL into mobile vs. desktop groups (if URL has `m.` subdomain,
    use mobile interface), but only for users coming directly, not via a link
    clicked. For users coming via a link (if HTTP Referer header is set)
    this config will use User-Agent detection.

    When using this config, you will have to perform redirects in your app if
    the URL which user requested doesn't match their device type.
    (E.g. if the user comes to 'm.foo.com' via a link, but Mobvious tells you
    that their device is a desktop computer, make sure to redirect the user
    immediately to 'foo.com'.)

        Mobvious.configure do |config|
          config.strategies = [
            Mobvious::Strategies::URL.new(:mobile_path, disable_if_referer_set: true),
            Mobvious::Strategies::MobileESP.new
          ]
        end


## Detection Strategies

### MobileESP (User-Agent sniffing)

`Mobvious::Strategies::MobileESP` | [view docs](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/MobileESP)

Selects the device type using information present in the User-Agent HTTP header.

[Constructor](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/MobileESP#initialize-instance_method)
takes a detection procedure.
Detection procedure decides what device type it should return based on the
information it can dig out of MobileESPConverted::UserAgentInfo instance.

There are two predefined detection procedures (and you can write your own):

*   `:mobile_desktop` (this is the default)
    distinguishes between `:mobile` and `:desktop`. Tablets
    are reported as `:desktop`, because their screens are usually large enough to handle
    web interfaces meant for desktops.

*   `:mobile_tablet_desktop` distinguishes between `:mobile`, `:tablet`
    and `:desktop`.

### URL (URL pattern matching)

`Mobvious::Strategies::URL` | [view docs](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/URL)

Selects the device type by matching a pattern against the request's URL (whole URL,
including protocol information).

[Constructor](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/URL#initialize-instance_method)
takes a hash of rules in format `{ /regular_expression/ => :device_type }` and options. Using the options you
can disable this strategy for requests that have the Referer HTTP header set or matching / not matching some
regular expression
([see docs](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/URL#initialize-instance_method)).
This is useful if you want to exclude URL detection for users coming via links from other sites and let the
User-Agent detection take precedence.

There is one predefined rule set:

*   `:mobile_path` detects all URLs that begin with m. (e.g. `http://m.foo.com/`)
    as `:mobile`. Doesn't make assumption about other URLs (the detection process
    continues to the next strategy in order).

### Cookie (remembering user's manual choice)

`Mobvious::Strategies::Cookie` | [view docs](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/Cookie)

This strategy is useful when user should be able to make a manual switch between
interface versions and you want all the interface versions running on the exact same URL.

Call this anywhere in your app:

        Mobvious.strategy('Cookie').set_device_type(response, :desktop)
        
… and Mobvious will report `:desktop` from now on for this particular user, regardless
of what is his/her real device type. (Response parameter is your Rack::Response instance.
In Rails it is accessible simply by writing `response`, as shown in the code example above.)
Make sure to put the Cookie strategy high enough in your strategies array
(the first entry?) so it does not get overriden by some other strategy.

[Constructor](http://rdoc.info/github/jistr/mobvious/master/Mobvious/Strategies/Cookie#initialize-instance_method)
takes an array of allowed device types ("whitelist") that your
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