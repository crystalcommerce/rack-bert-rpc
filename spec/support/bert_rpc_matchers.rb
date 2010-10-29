module BertRpcMatchers
  RSpec::Matchers.define :be_a_user_error do
    match do |actual|
      d = BertRpcMatchers.decode(actual.body)
      d[0] == :error &&
        d[1][0] == :user
    end
  end

  RSpec::Matchers.define :be_a_server_error do
    match do |actual|
      d = BertRpcMatchers.decode(actual.body)
      d[0] == :error &&
        d[1][0] == :server
    end
  end

  RSpec::Matchers.define :eql_bert do |expected|
    match do |actual|
      d = BertRpcMatchers.decode(actual.body)
      d == expected
    end
  end

  def self.decode(berp)
    io = StringIO.new(berp)
    length = io.read(4).unpack("N").first
    BERT.decode(io.read(length))
  end
end
