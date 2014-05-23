
define :ssh_authorized_keys do
  params[:action] or params[:action] = :append
  username = params[:user]
  username or raise ArgumentError, "ssh_authorized_keys expects username"
  newkeys  = Array(params[:keys])
  authkeys = node.default['ssh-util']['authorized_keys']

  if !newkeys.empty? && params[:action] == :append
    current = (authkeys.has_key?(username) ? authkeys[username] : [])
    resulting = current | newkeys
  elsif !newkeys.empty? && params[:action] == :remove
    purging = newkeys.map {|str| Chef::Provider::SshUtil.public_key_from(str)}
    current = (authkeys.has_key?(username) ? authkeys[username] : [])
    unless current.empty?
      resulting = current.select {|str| not purging.include?(Chef::Provider::SshUtil.public_key_from(str))}
    end
  end
  authkeys[username] = resulting if resulting
end
