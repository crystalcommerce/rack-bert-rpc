# We prefer to not define a global 't' method so we will use Crystal Commerce's
# fork of Bert if it is available.
# http://github.com/crystalcommerce/bert
begin
  require 'bert/core'
rescue LoadError
  require 'bert'
end

module Rack
  class BertRpc
    module Encoding
      def read_rpc(input)
        raw = input.read(4)
        return nil unless raw
        length = raw.unpack('N').first
        return nil unless length
        bert = input.read(length)
        BERT.decode(bert)
      end

      def error_response(type, error)
        if error.is_a? String
          berpify(BERT.encode(BERT::Tuple[:error,
                                BERT::Tuple[type, 0, error]]))
        else
          berpify(BERT.encode(BERT::Tuple[:error,
                                BERT::Tuple[type, 0, error.class.to_s,
                                  error.message, error.backtrace]]))
        end
      end

      def reply_response(response)
        berpify(BERT.encode(BERT::Tuple[:reply, response]))
      end

      def noreply_response
        berpify(BERT.encode(BERT::Tuple[:noreply]))
      end

      private

      def berpify(msg)
        [msg.length].pack("N") + msg
      end
    end
  end
end
