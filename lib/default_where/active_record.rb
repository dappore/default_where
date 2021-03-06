# frozen_string_literal: true

module DefaultWhere
  module ActiveRecord
    PATTERN = {
      gt: '>',
      gte: '>=',
      lt: '<',
      lte: '<=',
      not: '!=',
      like: 'like',
      rl: 'like',
      ll: 'like',
      '': '='
    }.freeze
    
    def default_where_scope(params)
      where_string = []
      where_hash = {}

      params.each do |key, value|
        real_key, sign_str = key.split('-')
        agent_key = key.gsub(/[-.\/]/, '_')
        
        if value.nil? || value == []
          if sign_str == 'not'
            where_string << "#{real_key} IS NOT NULL"
          elsif sign_str.nil?
            where_string << "#{real_key} IS NULL"
          else
            raise "#{key}'s value can not be nil"
          end
        elsif sign_str == 'any'
          where_string << ":#{agent_key} = ANY(#{real_key})"
          where_hash.merge! agent_key.to_sym => value
        elsif real_key.match? /.\/./
          real_key, i18n_key = key.split('/')
          where_string << "#{real_key}->>'#{i18n_key}' = :#{agent_key}"
          where_hash.merge! agent_key.to_sym => value
        else
          case sign_str
          when 'll'
            real_value = "#{value}%"
          when 'rl'
            real_value = "%#{value}"
          when 'like'
            real_value = "%#{value}%"
          else
            real_value = value
          end
          
          where_string << "#{real_key} #{PATTERN[sign_str.to_s.to_sym]} :#{agent_key}"
          where_hash.merge! agent_key.to_sym => real_value
        end
      end
      
      [where_string, where_hash]
    end
    
  end
end
