

Okdoki
----------

A POL/DSL for micro-web apps to
make for your friends and enemies.

Common Tasks
-----------------

    # === Creating model file:
    # === Creating route files:
    # === Create test/spec files:
    bin/template examples

    # === Create migration files:
    bin/migrate create My\_Model table


Architecture
------------

* Customer and Screen Name oriented
* No Computer generated code. Just settings and "subscriptions".
* Limit the creation of tables as much as possible.
  Forcing the use of Consume, you will sooner or later see a better solution.
  Example: Banning and exceptions. When you ban a customer,
  screen name, or customer, you still want to see their content
  occasionally. It's easy to just create tables.
    banning options: Ban as editor/author, ban all content,
    ban from sending me messages
    + 5 page exception limit
    + (exceptions as settings)

Complexity
----------

* Permissions w/complex logic. Example:
     These people in this group of mine can see it,
     but not this group OR this one either.
     And esp. not my ex-bfs/ex-gfs who I have
     not talked to in the past 2 years.

  This is not going to be implemented any time soon.
  Instead, privacy will be simple for now:
    centered around "lifes" (ie screen names) which
    an account can have multiple.
  Privacy is further implemented in secret messages that only
  specified individuals can read.
  More privacy can be created by creating a special screen name
  meant only for a small circle of friends.

  I associate complex privacy/permissions with office/producitivty,
  not with friendship fun.

  The reason for the lack of complex permissions is the cost
  in implementing them for feeds/streams.  Right now Okdoki
  is a simple Ruby app with a couple of functions and SQL calls.

* Authorization (aka Permission):
  * "Consumer" -> "Multi. Producers" (inbox)
  * "Consumer" -> "Producer"         (screen name homepage)

  Temp answer: Screen name orientation, sub-queries

* One Customer, Multi. Screen Names

  Temp answer:
    Unique ids, same table for SN, sub-SNs.
    <br />
    Different table for group based permission.

F.A.Q.
------

* How are authorization for actions done at the model level?

  The USER is obtained from the session and validations
  are used to ensure USER is allowed to do the intended
  action.

* How do I create a `:initialize` method on a model class?

  Initialize all values other than `@data`. Then, call `super(@data)`
  Doing it any other way increases the chance that you create
  an instance with `@data = nil`.

        def initialize *args
          @screen_name = if args.size == 2
                           args.pop
                         else
                           nil
                         end
          super(*args)
        end

* How do I create a `:read` method on a model class?

        class Screen_Name
          class << self
            def read_by_something something
              new TABLE.limit(1)[:something=>something], "Screen name not found."
            end
          end
        end

* How do I create an `:update` method on a model class?

  Update the record, then `:merge!` w/ @data
        def update data
          # Whatever you want.
          # Then update @data
          @data.merge!(
             TABLE.returning.where(...).update(...).
             first || {}
          )
        end

Conversation Characteristics
----------------

Automated: Games, Archives
Privacy:   All, Select (Email, etc.)
Time:      Instant (IM, Chat), Delayed (Email, Comments, etc.)
Space:     by default, Internet
Reliability:
  Payment
  "I know this person"
  Possible Friend (topic websites + surveys)








