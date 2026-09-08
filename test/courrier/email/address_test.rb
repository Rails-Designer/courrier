require "test_helper"
require "courrier/email/address"

class Courrier::Email::AddressTest < Minitest::Test
  def test_with_name_basic_formatting
    assert_equal "Rails Designer <devs@railsdesigner.com>",
      Courrier::Email::Address.with_name("devs@railsdesigner.com", "Rails Designer")
  end

  def test_with_name_requires_address
    error = assert_raises(Courrier::ArgumentError) do
      Courrier::Email::Address.with_name(nil, "Rails Designer")
    end
    assert_equal "Both `address` and `name` are required", error.message
  end

  def test_with_name_requires_name
    error = assert_raises(Courrier::ArgumentError) do
      Courrier::Email::Address.with_name("devs@railsdesigner.com", nil)
    end
    assert_equal "Both `address` and `name` are required", error.message
  end

  def test_with_name_requires_non_empty_address
    error = assert_raises(Courrier::ArgumentError) do
      Courrier::Email::Address.with_name("", "Rails Designer")
    end
    assert_equal "Both `address` and `name` must not be empty", error.message
  end

  def test_with_name_requires_non_empty_name
    error = assert_raises(Courrier::ArgumentError) do
      Courrier::Email::Address.with_name("devs@railsdesigner.com", "")
    end
    assert_equal "Both `address` and `name` must not be empty", error.message
  end

  def test_with_name_quotes_special_characters
    assert_equal "\"Doe, John\" <devs@railsdesigner.com>",
      Courrier::Email::Address.with_name("devs@railsdesigner.com", "Doe, John")
  end

  def test_with_name_escapes_quotes
    assert_equal "\"John \\\"Johnny\\\" Doe\" <devs@railsdesigner.com>",
      Courrier::Email::Address.with_name("devs@railsdesigner.com", 'John "Johnny" Doe')
  end

  def test_with_name_quotes_and_escapes_a_backslash
    assert_equal "\"C:\\\\Users, Inc\" <devs@railsdesigner.com>",
      Courrier::Email::Address.with_name("devs@railsdesigner.com", 'C:\Users, Inc')
  end

  # A trailing backslash would otherwise escape the closing quote and run the
  # display name into the address.
  def test_with_name_escapes_a_trailing_backslash
    assert_equal "\"Doe\\\\\" <devs@railsdesigner.com>",
      Courrier::Email::Address.with_name("devs@railsdesigner.com", 'Doe\\')
  end
end
