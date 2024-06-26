# frozen_string_literal: true

require 'uri'

module Aws
  module Rest
    module Request
      class Endpoint

        # @param [Seahorse::Model::Shapes::ShapeRef] rules
        # @param [String] request_uri_pattern
        def initialize(rules, request_uri_pattern)
          @rules = rules
          request_uri_pattern.split('?').tap do |path_part, query_part|
            @path_pattern = path_part
            @query_prefix = query_part
          end
        end

        # @param [URI::HTTPS,URI::HTTP] base_uri
        # @param [Hash,Struct] params
        # @return [URI::HTTPS,URI::HTTP]
        def uri(base_uri, params)
          uri = URI.parse(base_uri.to_s)
          apply_path_params(uri, params)
          apply_querystring_params(uri, params)
          uri
        end

        private

        def apply_path_params(uri, params)
          path = uri.path.sub(%r{/$}, '')
          # handle trailing slash
          path += @path_pattern.split('?')[0] if path.empty? || @path_pattern != '/'
          uri.path = path.gsub(/{.+?}/) do |placeholder|
            param_value_for_placeholder(placeholder, params)
          end
        end

        def param_value_for_placeholder(placeholder, params)
          name = param_name(placeholder)
          param_shape = @rules.shape.member(name).shape
          value =
            case param_shape
            when Seahorse::Model::Shapes::TimestampShape
              timestamp(param_shape, params[name]).to_s
            else
              params[name].to_s
            end

          raise ArgumentError, ":#{name} must not be blank" if value.empty?

          if placeholder.include?('+')
            value.gsub(%r{[^/]+}) { |v| escape(v) }
          else
            escape(value)
          end
        end

        def param_name(placeholder)
          location_name = placeholder.gsub(/[{}+]/, '')
          param_name, _ = @rules.shape.member_by_location_name(location_name)
          param_name
        end

        def timestamp(ref, value)
          case ref['timestampFormat']
          when 'unixTimestamp' then value.to_i
          when 'rfc822' then value.utc.httpdate
          else
            # serializing as RFC 3399 date-time is the default
            value.utc.iso8601
          end
        end

        def apply_querystring_params(uri, params)
          # collect params that are supposed to be part of the query string
          parts = @rules.shape.members.inject([]) do |prts, (member_name, member_ref)|
            if member_ref.location == 'querystring' && !params[member_name].nil?
              prts << [member_ref, params[member_name]]
            end
            prts
          end
          querystring = QuerystringBuilder.new.build(parts)
          querystring = [@query_prefix, querystring == '' ? nil : querystring].compact.join('&')
          querystring = nil if querystring == ''
          uri.query = querystring
        end

        def escape(string)
          Seahorse::Util.uri_escape(string)
        end

      end
    end
  end
end
