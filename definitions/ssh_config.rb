
define :ssh_config do
  params[:action] or params[:action] = :append
  username = params[:user] or raise ArgumentError "ssh_config requires user attribute"
  options = Mash.new(params[:options])
  base = node.default['ssh-util']['ssh_config_user']
  if !options.empty? && params[:action] == :append
    # we do deep merge of the default level cookbook attributes
    result = Chef::Mixin::DeepMerge.deep_merge(base[username], options)
    base[username] = result
  elsif 
    raise ArgumentError, "ssh_config action :#{params[:action]} is not supported"
  end
end