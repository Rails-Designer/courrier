# frozen_string_literal: true

require "test_helper"

class Courrier::TestModeTest < Minitest::Test
  include TestEmailHelpers

  def setup
    reset_test_email_class
    reset_configuration
    Courrier::TestMode.clear!
  end

  def teardown
    Courrier::TestMode.clear!
  end

  def test_deliveries_starts_empty
    assert_empty Courrier::TestMode.deliveries
  end

  def test_clear_resets_deliveries
    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    assert_equal 1, Courrier::TestMode.deliveries.size

    Courrier::TestMode.clear!

    assert_empty Courrier::TestMode.deliveries
  end

  def test_records_delivery
    Courrier::Email::Provider.stub :new, mock_provider do
      TestEmail.new(from: "devs@railsdesigner.com", to: "recipient@railsdesigner.com").deliver
    end

    delivery = Courrier::TestMode.deliveries.first
    assert_equal "TestEmail", delivery.email_class
    assert_equal "recipient@railsdesigner.com", delivery.to
    assert_equal "devs@railsdesigner.com", delivery.from
    assert_equal "Test Subject", delivery.subject
    assert_instance_of Courrier::Email::Result, delivery.result
  end

  def test_records_multiple_deliveries
    Courrier::Email::Provider.stub :new, mock_provider do
      3.times do |i|
        TestEmail.new(from: "devs@railsdesigner.com", to: "recipient#{i}@railsdesigner.com").deliver
      end
    end

    assert_equal 3, Courrier::TestMode.deliveries.size
  end

  private

  def mock_provider
    @mock_provider ||= Object.new.tap do |mock|
      def mock.deliver

        Courrier::Email::Result.new(response: Data.define(:code, :body).new(code: "200", body: '{"success": true}'))
      end
    end
  end
end
