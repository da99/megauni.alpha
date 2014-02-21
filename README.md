

Common Tasks
-----------------

    bin/model create My\_Model

    bin/migrate create My\_Model table


Okdoki.com
----------

Friendship-based activities.


Complexity
----------

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

* How do I create a :read method?

        class Screen_Name
          class << self
            def read_by_something something
              new TABLE.limit(1)[:something=>something], "Screen name not found."
            end
          end
        end

* How do I test a file?

        # --- Either one of the following:
        bin/bundle exec bacon tests/MODEL/0X-action.rb
        bin/test   fast tests/MODEL/0X-action.rb

        # --- or with `bin/migrate reset`:
        bin/test        tests/MODEL/0X-action.rb









