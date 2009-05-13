# BioCatalogue: lib/bio_catalogue/faceting.rb
#
# Copyright (c) 2009, University of Manchester, The European Bioinformatics 
# Institute (EMBL-EBI) and the University of Southampton.
# See license.txt for details

# Module to carry out the bulk of the logic for filtering, faceting,
# advanced search, and so on.

module BioCatalogue
  module Faceting
    
    # Gets all the service providers and their counts of services.
    # Example return data:
    # [ { "name" => "ebi.ac.uk", "count" => "12" }, { "name" => "example.com", "count" => "11" }, ... ]
    def self.get_facets_for_service_providers(limit=nil)
      # NOTE: this query has only been tested to work with MySQL 5.0.x
      sql = "SELECT service_providers.name AS name, COUNT(*) AS count 
            FROM service_providers 
            INNER JOIN service_deployments ON service_providers.id = service_deployments.service_provider_id 
            INNER JOIN services ON services.id = service_deployments.service_id 
            GROUP BY service_providers.id 
            ORDER BY COUNT(*) DESC"
      
      # If limit has been provided in the URL then add that to query.
      if !limit.nil? && limit.is_a?(Fixnum) && limit > 0
        sql += " LIMIT #{limit}"
      end
       
      return ActiveRecord::Base.connection.select_all(sql)
    end
    
    # Gets all the different service types and their counts of services.
    # Example return data:
    # [ { "name" => "SOAP", "count" => "102" }, { "name" => "REST", "count" => "11" }, ... ]
    def self.get_facets_for_service_types(limit=nil)
      facets = { }
      
      # NOTE: this query has only been tested to work with MySQL 5.0.x
      sql = "SELECT service_versions.service_versionified_type AS name, COUNT(*) AS count 
            FROM service_versions 
            INNER JOIN services ON services.id = service_versions.service_id 
            GROUP BY service_versions.service_versionified_type 
            ORDER BY COUNT(*) DESC"
      
      # If limit has been provided in the URL then add that to query.
      if !limit.nil? && limit.is_a?(Fixnum) && limit > 0
        sql += " LIMIT #{limit}"
      end
       
      facets = ActiveRecord::Base.connection.select_all(sql)
      
      # Need to "massage" the returned data...
      
      facets.each do |f|
        f["name"] = f["name"].constantize.new.service_type_name
      end
      
      return facets
    end
    
    def self.filter_type_to_display_name(filter_type)
      case filter_type
        when :t
          "Service Types"
        when :p
          "Service Providers"
        else
          "(unknown)"
      end
    end
    
    # ======================================
    # Facet URL generation / parsing helpers
    # --------------------------------------

    # Filters are specified via the query parameters in URLs.
    # The general format for this is:
    #   ...?filter_type_1=[value1],[value2],[value3]&filter_type_2=[value4]&filter_type_3=[value5],[value6]&...
    
    # Returns back a cloned params object with the new filter specified within it.
    def self.add_filter_to_params(params, filter_type, filter_value)
      params_dup = BioCatalogue::Util.duplicate_params(params)
    
      if params_dup[filter_type].blank?
        params_dup[filter_type] = "[#{filter_value}]"
      else
        params_dup[filter_type] << ",[#{filter_value}]"
      end
      
      # Reset page param
      params_dup.delete(:page)
      
      return params_dup
    end
    
    # Returns back a cloned params object with the filter specified removed from it.
    def self.remove_filter_to_params(params, filter_type, filter_value)
      params_dup = BioCatalogue::Util.duplicate_params(params)
    
      unless params_dup[filter_type].blank?
        params_dup[filter_type].gsub!(",[#{filter_value}]", "")
        params_dup[filter_type].gsub!("[#{filter_value}]", "")
      end
      
      params_dup.delete(filter_type) if params_dup[filter_type].blank?
      
      # Reset page param
      params_dup.delete(:page)
      
      return params_dup
    end
    
    def self.is_filter_selected(params, filter_type, filter_value)
      return params[filter_type] && self.split_filter_options_string(params[filter_type]).include?(filter_value)
    end
    
    # Returns:
    #   [ conditions, joins ] for use in an ActiveRecord .find method (or .paginate).
    def self.generate_conditions_and_joins_from_filters(params)
      conditions = { }
      joins = [ ]
      
      # Get the necessary filters from the params object, in a more structured form...
      filters = self.convert_params_to_filters(params) 
      
      # Now build the conditions and joins...
      
      unless filters.blank?
        filters.each do |filter_type, filter_values|
          unless filter_values.blank?
            case filter_type
              when :t
                service_types = [ ]
                filter_values.each do |f|
                  # TODO: strip this out into a more generic mapping table (prob in config or lib)
                  case f.downcase
                    when 'soap'
                      service_types << 'SoapService'
                    when 'rest'
                      service_types << 'RestService'
                  end
                end
                
                unless service_types.blank?
                  conditions[:service_versions] = { :service_versionified_type => service_types }
                  joins << :service_versions
                end
              when :p
                provider = filter_values
                
                unless provider.blank?
                  conditions[:service_deployments] = { :service_providers => { :name => provider } }
                  joins << [ { :service_deployments => :provider } ]
                end
            end
          end
        end
      end
      
      return [ conditions, joins ]
    end
    
    # Converts the params from a URL query string into a more structured filters collection.
    # Example return value:
    #   { :t => [ "SOAP" ], :p => [ "ebi.ac.uk", "ddbj.jp" ] }
    #
    # Note: irrelevant query parameters will be ignored and left untouched.
    def self.convert_params_to_filters(params)
      filters = { }
      
      params.each do |key, values|
        case key.to_s.downcase
          when 't'
            filters[:t] = filter_options = self.split_filter_options_string(values)
          when 'p'
            filters[:p] = filter_options = self.split_filter_options_string(values)
        end
      end
      
      return filters
    end
    
    # Remember the query format (mentioned above):
    # ...?filter_type_1=[value1],[value2],[value3]&filter_type_2=[value4]&filter_type_3=[value5],[value6]&...
    # This method splits one set of values for one filter_type into an array of values.
    def self.split_filter_options_string(filter_options)
      filter_options = filter_options.split("],[")
      
      # Now the first item will have a '[' at the beginning, and the last item will have a ']'...
      
      first_value = filter_options[0]
      first_value_length = first_value.length
      filter_options[0] = first_value[1...first_value_length]
      
      last_value = filter_options[filter_options.length-1]
      last_value_length = last_value.length
      filter_options[filter_options.length-1] = last_value[0...last_value_length-1]
      
      return filter_options
   end
   
   # ======================================
  end
end