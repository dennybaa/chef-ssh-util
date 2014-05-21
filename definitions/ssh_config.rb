
define :ssh_config, :action => :append do
  username = params[:user]
  options = Mash.new(params[:options])

  if username.nil?
    base = node.default['ssh-util']
    nleave = 'ssh_config'
  else
    base = node.default['ssh-util']['ssh_config_user']
    nleave = username
  end

  if !options.empty? && params[:action] == :append
    # we do deep merge of the default level cookbook attributes
    result = Chef::Mixin::DeepMerge.deep_merge(base[nleave], options)
    base[nleave] = result
  elsif 
    raise ArgumentError, "ssh_config action :#{params[:action]} is not supported"
  end
end
