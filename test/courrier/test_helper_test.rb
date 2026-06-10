# frozen_string_literal: true

require "test_helper"

class Courrier::TestHelperTest < Minitest::Test
  include TestEmailHelpers
  include Courrier::TestHelper

  def setup
    reset_test_email_class
    reset_configuration

    Courrier::TestMode.clear!
  end

  def teardown
    Courrier::TestMode.clear!
  end

  def test_assert_emails_delivered_passes_with_correct_count
    deliver_email(count: 3)

    assert_emails_delivered(3)
  end

  def test_assert_emails_delivered_fails_with_wrong_count
    deliver_email(count: 2)

    error = assert_raises Minitest::Assertion do
      assert_emails_delivered(3)
    end

    assert_includes error.message, "Expected 3 email(s) to be delivered, but 2 were delivered"
  end

  def test_assert_no_emails_delivered_passes_when_empty
    assert_no_emails_delivered
  end

  def test_assert_no_emails_delivered_fails_when_emails_exist
    deliver_email(count: 1)

    error = assert_raises Minitest::Assertion do
      assert_no_emails_delivered
    end

    assert_includes error.message, "Expected 0 email(s) to be delivered, but 1 were delivered"
  end

  def test_assert_email_delivered_matches_by_class
    deliver_email(count: 1)

    assert_email_delivered(TestEmail)
  end

  def test_assert_email_delivered_matches_by_class_name
    deliver_email(count: 1)

    assert_email_delivered("TestEmail")
  end

  def test_assert_email_delivered_matches_by_to
    deliver_email(count: 2, to: "specific@example.com")

    assert_email_delivered(to: "specific@example.com")
  end

  def test_assert_email_delivered_matches_by_from
    deliver_email(count: 1, from: "sender@example.com")

    assert_email_delivered(from: "sender@example.com")
  end

  def test_assert_email_delivered_matches_by_subject
    deliver_email(count: 1)

    assert_email_delivered(subject: "Test")
  end

  def test_assert_email_delivered_matches_by_provider
    deliver_email(count: 1, provider: "postmark")

    assert_email_delivered(provider: "postmark")
  end

  def test_assert_email_delivered_matches_with_multiple_criteria
    deliver_email(count: 1, from: "devs@railsdesigner.com", to: "test@example.com")

    assert_email_delivered(from: "devs@railsdesigner.com", to: "test@example.com")
  end

  def test_assert_email_delivered_fails_with_no_match
    deliver_email(count: 1, to: "other@example.com")

    error = assert_raises Minitest::Assertion do
      assert_email_delivered(to: "nonexistent@example.com")
    end

    assert_includes error.message, "to=nonexistent@example.com"
    assert_includes error.message, "1 email(s) delivered"
  end

  def test_assert_email_delivered_fails_with_wrong_class
    deliver_email(count: 1)

    error = assert_raises Minitest::Assertion do
      assert_email_delivered("WrongClass")
    end

    assert_includes error.message, "email_class=WrongClass"
  end

  private

  def deliver_email(count:, to: "recipient@railsdesigner.com", from: "devs@railsdesigner.com", provider: "logger")
    Courrier::Email::Provider.stub :new, create_mock_provider do
      count.times do
        TestEmail.new(
          from: from,
          to: to,
          provider: provider
        ).deliver
      end
    end
  end
end
