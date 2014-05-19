
define :ssh_config, :action => :append do
  if (params[:hosts].nil? || params[:hosts].empty?) && (params[:options].nil? || params[:options].empty?)
    Chef::Log.warn "ssh_config[#{params[:name]}] empty configuration, no action will be taken"
  else
    self.singleton_class.send(:include, SSHUtil::Config)
    opts = ssh_prepare_opts # prepare default options
    ssh_template_resource # create a single copy of the config template

    base = (opts[:config_global] ? node.default['ssh-util']['ssh_config'] :
      node.default['ssh-util']['user_ssh_config'][opts[:user]])

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
