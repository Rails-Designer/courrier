module TestEmailHelpers
  def reset_test_email_class
    TestEmail.provider = nil
    TestEmail.api_key = nil
    TestEmail.from = nil
    TestEmail.reply_to = nil
    TestEmail.cc = nil
    TestEmail.bcc = nil
  end

  def reset_configuration
    Courrier.configuration = Courrier::Configuration.new
  end

  def create_mock_provider
    mock_provider = Object.new

    def mock_provider.deliver
      "delivery_result"
    end

    mock_provider
  end
end
