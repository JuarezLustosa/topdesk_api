# tested via spec/middleware/response/raise_error_spec.rb
module TopdeskAPI
  module Error
    class ClientError < Faraday::Error::ClientError
      attr_reader :wrapped_exception

      def to_s
        if response
          "#{super} -- #{response.method} #{response.url}"
        else
          super
        end
      end
    end

    class RecordInvalid < ClientError
      attr_accessor :errors

      def initialize(*)
        super

        @errors = response[:body]['details'] || response[:body]['description'] if response[:body].is_a?(Hash)

        @errors ||= {}
      end

      def to_s
        "#{self.class.name}: #{@errors}"
      end
    end

    class NetworkError < ClientError; end
    class RecordNotFound < ClientError; end
    class RateLimited < ClientError; end
  end
end
