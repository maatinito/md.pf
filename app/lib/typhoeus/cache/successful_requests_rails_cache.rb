module Typhoeus
  module Cache
    # Cache successful Typhoeus requests in the Rails cache
    # (and don’t cache failed requests).
    #
    # Usage:
    #   Typhoeus.get('http://exemple.com/api', cache: DS::Typhoeus::Cache::RailsSuccess.new, cache_ttl: 1.day)
    class SuccessfulRequestsRailsCache
      def get(request)
        ::Rails.cache.read(request)
      end

      def set(request, response)
        if response&.success?
          ::Rails.cache.write(request, response, :expires_in => request.cache_ttl)
        end
      end
    end
  end
end
