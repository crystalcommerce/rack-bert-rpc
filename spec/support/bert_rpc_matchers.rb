module BertRpcMatchers
  RSpec::Matchers.define :be_a_user_error do
    failure_message_for_should do |actual|
      "expected #{BertRpcMatchers.decode(actual)} to be a user error"
    end

    failure_message_for_should_not do |actual|
      "expected #{BertRpcMatchers.decode(actual)} to not be a user error"
    end

    match do |actual|
      d = BertRpcMatchers.decode(actual)
      d[0] == :error &&
        d[1][0] == :user
    end
  end

  RSpec::Matchers.define :be_a_server_error do
    failure_message_for_should do |actual|
      "expected #{BertRpcMatchers.decode(actual).inspect} to be a server error"
    end

    failure_message_for_should_not do |actual|
      "expected #{BertRpcMatchers.decode(actual).inspect} to not be a " +
        "server error"
    end

    match do |actual|
      d = BertRpcMatchers.decode(actual)
      d[0] == :error &&
        d[1][0] == :server
    end
  end

  RSpec::Matchers.define :eql_bert do |expected|
    match do |actual|
      d = BertRpcMatchers.decode(actual)
      d == expected
    end
  end

  def self.decode(response)
    io = StringIO.new(response.body)
    length = io.read(4).unpack("N").first
    BERT.decode(io.read(length))
  end
end
