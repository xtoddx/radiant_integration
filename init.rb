# load some active record initialization
# (just for beast)
require File.join(RAILS_ROOT, 'config', 'initializers', 'active_record')
require File.join(RAILS_ROOT, 'config', 'initializers', 'concerns')

# from a plugin in radiant
class ActiveRecord::Base
  def self.object_id_attr(symbol, klass)
    module_eval %{
      def #{symbol}
        if @#{symbol}.nil? or (@old_#{symbol}_id != #{symbol}_id)
          @old_#{symbol}_id = #{symbol}_id
          klass = #{klass}.descendants.find { |d| d.#{symbol}_name == #{symbol}_id }
          klass ||= #{klass}
          @#{symbol} = klass.new
        else
          @#{symbol}
        end
      end
    }
  end
end

# we use Dispatcher#to_prepare
require 'action_controller/dispatcher'

# load paths for radiant
require 'radiant'

base = File.dirname($:.select{|x| x =~ /radiant/ and x !~ /radiant_integration/}.first)

Dependencies.load_paths.push(File.join(base, 'lib'))
Dependencies.load_paths.push(File.join(base, 'app', 'models'))
Dependencies.load_paths.push(File.join(base, 'vendor', 'radius', 'lib'))

Dependencies.load_once_paths.push(File.join(base, 'lib'))
Dependencies.load_once_paths.push(File.join(base, 'app', 'models'))
Dependencies.load_once_paths.push(File.join(base, 'vendor', 'radius', 'lib'))

# in lib/local_time in radiant, there is a 'require'
$: << File.join(base, 'app', 'models')

require_dependency 'radius'

ActionController::Dispatcher.to_prepare do
  User.send :include, RadiantAuthentication
end

ActionController::Base.send :append_view_path,
                            File.join(File.dirname(__FILE__), 'views')

ActionView::Base.send :include, RadiantHelper

ActionController::Dispatcher.to_prepare do
  require_dependency 'application'
  ApplicationController.send :include, RadiantLayouts
  ApplicationController.send :radiant_layout, 'Beast'
end
