module JSONAPI::Consumer::Serializers
  class Stable
    attr_accessor :resource

    def initialize(resource, options = {})
      @resource = resource
      @options = options
    end

    def serialize
      @hash = resource.to_param.blank? ? resource.attributes.except(resource.class.primary_key) : resource.attributes

      @hash.merge!(type: resource.class.resource_name)

      resource.each_association do |name, association, options|
        @hash[:links] ||= {}

        if association.respond_to?(:each) or options.delete(:type) == :has_many
          add_links(name, association, options)
        else
          add_link(name, association, options)
        end
        @hash.delete(:links) if remove_links?
      end

      @hash
    end

    def add_links(name, association, options)
      @hash[:links][name] ||= []
      @hash[:links][name] += (association || []).map do |obj|
        case obj.class
          when String, Integer
            {id: obj, type: options.delete(:class).resource_name }
          else
            {id: obj.to_param, type: obj.class.resource_name}
        end
      end
    end

    def add_link(name, association, options)
      return if association.nil?

      @hash[:links][name] = case association.class
        when String, Integer
          {id: association, type: options.delete(:class).resource_name }
        else
          {id: association.to_param, type: association.class.resource_name }
      end
    end

    private

    def remove_links?
      if resource.persisted?
        false
      else # not persisted, new object
        if @hash[:links].length == 0 or @hash[:links].values.flatten.empty?
          true
        else
          false
        end
      end
    end

  end
end
