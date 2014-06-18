# ==== create user & group
group 'nagios' do
  group_name  'nagios'
  gid         600
  action      :create
end
user 'nagios' do
  comment  'nrpe'
  uid      600
  group    'nagios'
  home     '/usr/local/nagios'
  shell    '/bin/false'
  password nil
  supports :manage_home =>true
  action   [:create, :manage]
end

# ==== install packages
package "xinetd" do
  action :install
end

%w{nrpe nagios-plugins nagios-plugins-all}.each do |nrpe|
  package nrpe do
    action  :install
  end
end

# ==== start service
service "xinetd" do
  action   [ :enable, :start ]
  supports :reload => true
end

# === create custom plugins
cookbook_file "check_log3.pl" do
  source "check_log3.pl"
  path   "/usr/lib64/nagios/plugins/check_log3.pl"
  owner  "root"
  group  "root"
  mode   0755
  action :create
end
cookbook_file "check_proc_lin.pl" do
  source "check_proc_lin.pl"
  path   "/usr/lib64/nagios/plugins/check_proc_lin.pl"
  owner  "root"
  group  "root"
  mode   0755
  action :create
end
cookbook_file "check_vmstat_top5.pl" do
  source "check_vmstat_top5.pl"
  path   "/usr/lib64/nagios/plugins/check_vmstat_top5.pl"
  owner  "root"
  group  "root"
  mode   0755
  action :create
end

# ==== create xinetd config
template "/etc/xinetd.d/nrpe" do
  source  "xinetd_nrpe.erb"
  owner   "root"
  group   "root"
  mode    0644
  action  :create
  variables(
    :nagios_server => node["nrpe"]["nagios_server"]
  )
  notifies :reload, 'service[xinetd]'
end

# ==== create nrpe config
template "/etc/nagios/nrpe.cfg" do
  source  "nrpe_cfg.erb"
  owner   "root"
  group   "root"
  mode    0644
  action  :create
  variables(
    :nagios_server => node["nrpe"]["nagios_server"],
    :check_process => node["nrpe"]["check_process"]
  )
end