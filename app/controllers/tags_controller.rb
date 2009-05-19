# BioCatalogue: app/controllers/tags_controller.rb
#
# Copyright (c) 2009, University of Manchester, The European Bioinformatics 
# Institute (EMBL-EBI) and the University of Southampton.
# See license.txt for details.

class TagsController < ApplicationController
  before_filter :set_no_layout, :only => [ :auto_complete ]
  
  skip_before_filter :verify_authenticity_token, :only => [ :auto_complete ]
  
  before_filter :find_tags, :only => [ :index ]
  before_filter :find_tag_and_results, :only => [ :show ]
  
  def index
    respond_to do |format|
      format.html # index.rhtml
    end
  end
  
  def show
    respond_to do |format|
      format.html # show.rhtml
    end
  end
  
  def auto_complete
    tag_fragment = '';
    
    if params[:annotations] and params[:annotations][:tags]
      tag_fragment = params[:annotations][:tags]
    elsif  params[:annotation] and params[:annotation][:value]
      tag_fragment = params[:annotation][:value]
    end
    
    @tags = BioCatalogue::Tags.get_tag_suggestions(tag_fragment, 20)
                     
    render :inline => "<%= auto_complete_result @tags, 'name' %>"
  end
  
  # DELETE /tags
  def destroy
    annotatable = Annotation.find_annotatable(params[:annotatable_type], params[:annotatable_id])
    
    tag_name = params[:tag]
    
    if !annotatable.nil? and !tag_name.blank?
      existing = annotatable.annotations.find(:all, 
                                              :conditions => { :attribute_id => AnnotationAttribute.find_by_name("tag").id, 
                                                               :source_type => current_user.class.name,
                                                               :source_id => current_user.id,
                                                               :value => tag_name })
      annotatable.annotations.delete(existing)
    end
    
    respond_to do |format|
      format.html { render :partial => 'annotations/tags_box_inner_tag_cloud', 
                           :locals => { :tag_annotations => BioCatalogue::Annotations.get_tag_annotations_for_annotatable(annotatable),
                                        :annotatable => annotatable } }
    end
  end
  
protected

  def find_tags
    @tags = BioCatalogue::Tags.get_tags(params[:limit])
  end
  
  def find_tag_and_results
    @tag_name = BioCatalogue::Tags.get_tag_name_from_params(params)
    
    @count = 0
    @results = { }
    
    unless @tag_name.nil?
      tagged_items = Annotation.find_annotatables_with_attribute_name_and_value("tag", @tag_name)
      
      @count, @results = BioCatalogue::Util.group_model_objects(tagged_items, VALID_SEARCH_TYPES, true)
    end
  end
  
end
