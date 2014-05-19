
define :ssh_config, :action => :append do
  params[:user]  = params[:name]
  params[:owner] = params[:user] || 'root'

  if (params[:hosts].nil? || params[:hosts].empty?) && (params[:options].nil? || params[:options].empty?)
    Chef::Log.warn "ssh_config[#{params[:name]}] empty configuration, no action will be taken"
  else
    self.singleton_class.send(:include, SSHUtil::Config)
    ssh_template_resource # create a single copy of the config template

    base = (params[:user] ? node.default['ssh-util']['user_ssh_config'][params[:user]] :
      node.default['ssh-util']['ssh_config'])

    if params[:action] == :append
      [:options, :hosts].each do |p|
        next if params[p].nil? || params[p].empty?
        if not params[p].respond_to?(:key)
          Chef::Log.error "ssh_config[#{params[:name]}] #{p} argument must be kind of hash when using :append action"
          raise ArgumentError, "Hash is expected"
        end
        base[p] = base[p].merge(params[p])
      end
    elsif params[:action] == :remove
      [:options, :hosts].each do |p|
        (params[p] || []).each {|k| base[p].delete(k)}
        base[p].empty? and base.delete(p)
      end
    end

  end
end
