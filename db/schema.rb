# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090423101749) do

  create_table "activity_logs", :force => true do |t|
    t.string   "action"
    t.string   "activity_loggable_type"
    t.integer  "activity_loggable_id"
    t.string   "culprit_type"
    t.integer  "culprit_id"
    t.string   "referenced_type"
    t.integer  "referenced_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "data",                   :limit => 16777215
  end

  create_table "agents", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annotation_attributes", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotation_attributes", ["name"], :name => "index_annotation_attributes_on_name"

  create_table "annotation_value_seeds", :force => true do |t|
    t.integer  "attribute_id", :null => false
    t.string   "value",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotation_value_seeds", ["attribute_id"], :name => "index_annotation_value_seeds_on_attribute_id"

  create_table "annotation_versions", :force => true do |t|
    t.integer  "annotation_id",                    :null => false
    t.integer  "version",                          :null => false
    t.integer  "version_creator_id"
    t.string   "source_type",                      :null => false
    t.integer  "source_id",                        :null => false
    t.string   "annotatable_type",   :limit => 50, :null => false
    t.integer  "annotatable_id",                   :null => false
    t.integer  "attribute_id",                     :null => false
    t.text     "value",                            :null => false
    t.string   "value_type",         :limit => 50, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotation_versions", ["annotation_id"], :name => "index_annotation_versions_on_annotation_id"

  create_table "annotations", :force => true do |t|
    t.string   "source_type",                                     :null => false
    t.integer  "source_id",                                       :null => false
    t.string   "annotatable_type",   :limit => 50,                :null => false
    t.integer  "annotatable_id",                                  :null => false
    t.integer  "attribute_id",                                    :null => false
    t.text     "value",                                           :null => false
    t.string   "value_type",         :limit => 50,                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                          :default => 1, :null => false
    t.integer  "version_creator_id"
  end

  add_index "annotations", ["annotatable_type", "annotatable_id"], :name => "index_annotations_on_annotatable_type_and_annotatable_id"
  add_index "annotations", ["attribute_id"], :name => "index_annotations_on_attribute_id"
  add_index "annotations", ["source_type", "source_id"], :name => "index_annotations_on_source_type_and_source_id"

  create_table "content_blobs", :force => true do |t|
    t.binary   "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "online_statuses", :force => true do |t|
    t.string   "status"
    t.integer  "pingable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pingable_type"
    t.string   "message",         :default => ""
    t.float    "connection_time", :default => 0.0
  end

  create_table "registries", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.text     "description"
    t.string   "homepage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.string   "subject_type", :null => false
    t.integer  "subject_id",   :null => false
    t.string   "predicate",    :null => false
    t.string   "object_type",  :null => false
    t.integer  "object_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rest_method_parameters", :force => true do |t|
    t.integer  "rest_method_id",    :null => false
    t.integer  "rest_parameter_id", :null => false
    t.string   "http_cycle",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rest_method_parameters", ["rest_method_id", "http_cycle"], :name => "index_rest_method_parameters_on_rest_method_id_and_http_cycle"
  add_index "rest_method_parameters", ["rest_method_id"], :name => "index_rest_method_parameters_on_rest_method_id"

  create_table "rest_method_representations", :force => true do |t|
    t.integer  "rest_method_id",         :null => false
    t.integer  "rest_representation_id", :null => false
    t.string   "http_cycle",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rest_method_representations", ["rest_representation_id", "http_cycle"], :name => "index_rest_method_representations_repid_and_httpcycle"
  add_index "rest_method_representations", ["rest_representation_id"], :name => "index_rest_method_representations_on_rest_representation_id"

  create_table "rest_methods", :force => true do |t|
    t.integer  "rest_resource_id", :null => false
    t.string   "method_type",      :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rest_methods", ["rest_resource_id"], :name => "index_rest_methods_on_rest_resource_id"

  create_table "rest_parameters", :force => true do |t|
    t.string   "name",                                   :null => false
    t.text     "description"
    t.string   "param_style",                            :null => false
    t.string   "computational_type"
    t.string   "default_value"
    t.boolean  "required",            :default => false
    t.boolean  "multiple",            :default => false
    t.boolean  "constrained",         :default => false
    t.text     "constrained_options"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rest_representations", :force => true do |t|
    t.string   "content_type", :null => false
    t.text     "description"
    t.string   "http_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rest_resources", :force => true do |t|
    t.integer  "rest_service_id",    :null => false
    t.string   "path",               :null => false
    t.text     "description"
    t.integer  "parent_resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rest_resources", ["rest_service_id"], :name => "index_rest_resources_on_rest_service_id"

  create_table "rest_services", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "interface_doc_url"
    t.string   "documentation_url"
  end

  create_table "service_deployments", :force => true do |t|
    t.integer  "service_id"
    t.integer  "service_version_id"
    t.string   "endpoint"
    t.integer  "service_provider_id"
    t.string   "city"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "submitter_id"
    t.string   "submitter_type"
  end

  create_table "service_providers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_tests", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "exec_name",                              :null => false
    t.string   "test_status",     :default => "Unknown"
    t.integer  "running_status",  :default => 0
    t.integer  "testable_id",                            :null => false
    t.string   "testable_type",                          :null => false
    t.text     "description",                            :null => false
    t.string   "filename",                               :null => false
    t.string   "content_type",                           :null => false
    t.integer  "user_id",                                :null => false
    t.integer  "content_blob_id",                        :null => false
    t.datetime "activated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_versions", :force => true do |t|
    t.integer  "service_id"
    t.integer  "service_versionified_id"
    t.string   "service_versionified_type"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_display_text"
    t.integer  "submitter_id"
    t.string   "submitter_type"
  end

  create_table "services", :force => true do |t|
    t.string   "unique_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "submitter_id"
    t.string   "submitter_type"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "soap_inputs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "soap_operation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "computational_type"
    t.integer  "min_occurs"
    t.integer  "max_occurs"
  end

  add_index "soap_inputs", ["soap_operation_id"], :name => "index_soap_inputs_on_soap_operation_id"

  create_table "soap_operations", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "soap_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parameter_order"
    t.string   "parent_port_type"
  end

  add_index "soap_operations", ["soap_service_id"], :name => "index_soap_operations_on_soap_service_id"

  create_table "soap_outputs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "soap_operation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "computational_type"
    t.integer  "min_occurs"
    t.integer  "max_occurs"
  end

  add_index "soap_outputs", ["soap_operation_id"], :name => "index_soap_outputs_on_soap_operation_id"

  create_table "soap_services", :force => true do |t|
    t.string   "name"
    t.string   "wsdl_location"
    t.text     "description"
    t.string   "documentation_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wsdl_file_id"
  end

  create_table "soaplab_servers", :force => true do |t|
    t.string   "name"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trash_records", :force => true do |t|
    t.string   "trashable_type"
    t.integer  "trashable_id"
    t.binary   "data",           :limit => 16777215
    t.datetime "created_at"
  end

  add_index "trash_records", ["created_at", "trashable_type"], :name => "index_trash_records_on_created_at_and_trashable_type"
  add_index "trash_records", ["trashable_type", "trashable_id"], :name => "index_trash_records_on_trashable_type_and_trashable_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "activated_at"
    t.string   "security_token"
    t.string   "display_name"
    t.string   "openid_url"
    t.integer  "role_id"
    t.text     "affiliation"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end