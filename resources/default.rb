actions :run
default_action :run

attribute :supports, :kind_of => Hash

def initialize(name, run_context=nil)
  super
  @supports = node['ssh-util']['default_supports']
end
