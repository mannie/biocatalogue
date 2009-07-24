# BioCatalogue: app/models/test_result.rb
#
# Copyright (c) 2009, University of Manchester, The European Bioinformatics
# Institute (EMBL-EBI) and the University of Southampton.
# See license.txt for details

class TestResult < ActiveRecord::Base
  if ENABLE_CACHE_MONEY
    is_cached :repository => $cache
    index :action
    index [ :test_type, :test_id ]
    index [ :test_type, :test_id, :action ]
  end
  
  #belongs_to :monitorable, :polymorphic => true
  
  # Helper class method to look up the object whose attribute
  # is being monitored given the monitorable class name and id 
  def self.find_monitorable(monitorable_str, monitorable_id)
    monitorable_str.constantize.find(monitorable_id)
  end 
  
  def monitorable
    TestResult.find_monitorable(self.test_type, self.test_id)
  end
  
  def self.new_with_unknown_status
    TestResult.new(:result => -1)
  end
  
  def self.results_for(monitorable_type, monitorable_id, limit=5)
    TestResult.find(:all,
                    :conditions =>  { :test_id => monitorable_id, :test_type => monitorable_type },
                    :order => "created_at DESC",
                    :limit => limit)
  end
end
