
define :ssh_config, :action => :append do
  if (params[:hosts].nil? || params[:hosts].empty?) && (params[:options].nil? || params[:options].empty?)
    Chef::Log.warn("ssh_config[#{params[:name]}] empty configuration, no action will be taken")
  else
    self.singleton_class.send(:include, SSHUtil::Config)
    # create the sole copy of template resource
    ssh_template_resource
    opts = ssh_config_opts

    base = node.default['ssh-util']['config_users'][opts[:owner]]
    if params[:action] == :append
      [:options, :hosts].each do |p|
        next if params[p].nil? || params[p].empty?
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
