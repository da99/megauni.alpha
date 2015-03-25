


class Test_Helper < Test::Unit::TestCase

  must 'raise a RuntimeError if a test is empty' do
    msg    = ":in `run': Empty test: :test_be_an_empty_test in file: tests/__test_The_Helper__1.rb"
    output = `ruby -r "tests/__helper__" tests/__test_The_Helper__1.rb 2>&1`
    assert_equal msg, output[msg]
  end

  must 'not raise anything if a test has an error' do
    msg    = "\n\n1 tests, 0 assertions, \e[37m\e[1m0 failures, \e[0m\e[0m\e[31m\e[1m1 errors"
    output = `ruby -r "tests/__helper__" tests/__test_The_Helper__2.rb`
    assert_equal msg, output[msg]
  end

  must 'not raise anything if a test has an assertion fail.' do
    msg    = "\n\n1 tests, 1 assertions, \e[31m\e[1m1 failures, \e[0m\e[0m\e[37m\e[1m0 errors"
    output = `ruby -r "tests/__helper__" tests/__test_The_Helper__3.rb`
    assert_equal msg, output[msg]
  end

end # === class Helper
