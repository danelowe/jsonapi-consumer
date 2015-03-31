module JSONAPI::Consumer::Query::Profiles
  class Stable
    def initialize(query)
      @query = query
    end

    def json_key
      @query.klass.resource_name
    end
  end
end
