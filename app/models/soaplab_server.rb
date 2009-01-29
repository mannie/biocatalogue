# BioCatalogue: app/models/soaplab_server.rb
#
# Copyright (c) 2008, University of Manchester, The European Bioinformatics 
# Institute (EMBL-EBI) and the University of Southampton.
# See license.txt for details

require 'open-uri'
require 'soap/wsdlDriver'
require 'ftools'

class SoaplabServer < ActiveRecord::Base
  acts_as_trashable
  
  acts_as_annotatable
  
  #validates_presence_of :name, :location
  validates_presence_of :location
  validates_uniqueness_of :location, :message => "already exists in BioCatalogue"
  validates_url_format_of :location,
                          :allow_nil => false
  #before_create :save_services
  #before_update :save_services
  #@service_urls = {}
  attr_accessor :wsdl_urls
  
  
  # save the soap services on this server in
  # the database
  def save_services(current_user)
    @error_urls        = []
    @existing_services = []
    #@new_services      = []
    @new_wsdls      = []
    @wsdl_urls         = get_info_from_server()[0]
    
    unless @wsdl_urls.empty?  
      @wsdl_urls.first(30).each { |url|
         soap_service  = SoapService.new({:wsdl_location => url})
         success, data = soap_service.populate
         dup = SoapService.check_duplicate(url, data["endpoint"])
      if success and dup != nil
         @existing_services << dup
         logger.info("This service exists in the database")
      else
        transaction do
          begin
            if success 
              c_success = soap_service.create_service(data["endpoint"], current_user, {:tag => 'soaplab'}) 
              if c_success
                #@new_services << soap_service.service(true)
                puts "checking the saving of this service...#{soap_service.service.class.to_s}"
                @new_services << SoapService.check_duplicate(url, data["endpoint"])
                logger.info("INFO: registered service - #{url}. SUCCESS:")
              else
                @error_urls << url
                logger.error("ERROR: post_create failed for service - #{url}. ")
              end
            end
          rescue Exception => ex
            @error_urls << url
            logger.error("ERROR: failed to register service - #{url}. soaplab registration Exception:")
            logger.error(ex)
          end
        end
      end
      }
    end
    return [@new_wsdls, @existing_services, @error_urls]
  end
    
  
  #Get list of wsdls and tools from server by using the soaplab server API
  def get_info_from_server(server_wsdl=self.location)   
    begin
      result = [] 
      proxy = SOAP::WSDLDriverFactory.new(server_wsdl).create_rpc_driver
      result = get_wsdls_and_tool_names(proxy)
    rescue
      errors.add_to_base("there were problems getting wsdls and tool names from server ")  
      result
    end
  end
  
  def get_wsdls_and_tool_names(proxy)
    wsdls = [self.location]
    base  = proxy.getServiceLocation("").return
    tools = proxy.getAvailableAnalyses("").return
    tools.each{ |t| wsdls << File.join(base, t+'?wsdl')}
    
    return [wsdls, tools]
  end
  
  def find_services_in_catalogue(wsdls =[])
    wsdls    = get_info_from_server()[0] if wsdls.empty?
    services = []
    wsdls.each{ |url|
         obj = SoapService.find(:first, :conditions => { :wsdl_location => url })
         services << (obj.nil? ? nil : obj.service)     
     }
     return services.compact
  end
 
  def create_groupings(wsdls=[])
    services = find_services_in_catalogue(wsdls)
    services.each{ |service|
    
    grouping = Grouping.new(:subject_type => service.class.to_s,
                            :subject_id =>service.id, 
                            :predicate =>'BioCatalogue:memberOf', 
                            :object_type => self.class.to_s,
                            :object_id =>self.id)
    grouping.save!
    }
  end
   
end
