module JSONAPI::Consumer
  module Resource
    module SerializerConcern
      extend ActiveSupport::Concern

      module ClassMethods
        def serializer_class
          @serializer ||= Serializers::Beta
        end
      end

      def serializable_hash(options = {})
        self.class.serializer_class.new(self, options).serialize
      end

      def to_json(options={})
        serializable_hash(options).to_json
      end

    end
  end
end
