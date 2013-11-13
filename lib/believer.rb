module Believer

  FEATURES = {}

  def self.features
    FEATURES
  end

end

require 'active_model'

begin
  require 'active_model/observing'
  Believer.features[:active_model_observing] = true
rescue LoadError => le
  begin
    require 'rails/observers/active_model'
    Believer.features[:active_model_observing] = true
  rescue LoadError => le
    Believer.features[:active_model_observing] = false
  end
end

require 'active_support/concern'
require 'active_support/core_ext'
require 'active_support/core_ext/module/delegation'

require 'cql'
require 'cql/client'

require 'yaml'

require 'believer/cql_helper'
require 'believer/environment/base_env'
require 'believer/environment/rails_env'
require 'believer/environment/merb_env'
require 'believer/environment'
require 'believer/connection'
require 'believer/key_space'
require 'believer/counter'
require 'believer/values'
require 'believer/column'
require 'believer/columns'
require 'believer/model_schema'
require 'believer/persistence'
require 'believer/command'
require 'believer/where_clause'
require 'believer/limit'
require 'believer/order_by'
require 'believer/filter_command'
require 'believer/act_as_enumerable'
require 'believer/query'
require 'believer/empty_result'
require 'believer/delete'
require 'believer/update'
require 'believer/insert'
require 'believer/querying'
require 'believer/scoping'
require 'believer/batch'
require 'believer/batch_delete'
require 'believer/callbacks'
require 'believer/finder_methods'

require 'believer/log_subscriber'

if Believer.features[:active_model_observing]
  require 'believer/observer'
end

require 'believer/relation'

require 'believer/create_table'
require 'believer/drop_table'
require 'believer/ddl'
require 'believer/counting'
require 'believer/base'

