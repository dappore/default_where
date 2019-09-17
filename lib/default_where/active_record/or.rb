# frozen_string_literal: true

module DefaultWhere
  module Or
    
    #
    #
    def default_or(params = {})
      return all if params.blank?
    
      keys = hash.keys
      query = where(keys[0] => hash[keys[0]])
    
      keys[1..-1].each do |key|
        query = query.or(where(key => hash[key]))
      end
    
      query
    end
    
    def or_scope(params)
      or_hash = {}

      params.each do |key, value|
        real_keys = key.split('-or-')
        
        real_keys.each do |real_key|
          if column_names.include?(real_key)
            real_key = "#{table_name}.#{real_key}"
          end

          where_hash.merge! real_key => value
        end
      end

      if where_hash.present?
        where.or(where(or_hash))
      else
        current_scope
      end
    end

    def filter_or(params)
      params.select do |k, _|
        k.include?('-or-')
      end
    end

  end
end

