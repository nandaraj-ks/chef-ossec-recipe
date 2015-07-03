#downloading and untaring ossec-hids
remote_file "/tmp/ossec-hids-2.8.2.tar.gz" do
 source "http://www.ossec.net/files/ossec-hids-2.8.2.tar.gz"
 mode 0644
end
execute 'ossec-hids-2.8.2' do
	command 'tar xzvf ossec-hids-2.8.2.tar.gz'
	cwd '/tmp'
end

#installing pexpect for below python script
file_dir = "/tmp"
file_name = "pexpect-2.3.tar.gz"
file_path = File.join(file_dir,file_name)
uncompressed_file_dir = File.join(file_dir, file_name.split(".tar.gz").first)

remote_file file_path do
  source "http://pexpect.sourceforge.net/pexpect-2.3.tar.gz"
  mode "0644"
  not_if { File.exists?(file_path) }
end

execute "gunzip ssl" do
  command "gunzip -c #{file_name} | tar xf -"
  cwd file_dir
  not_if { File.exists?(uncompressed_file_dir) }
end

installed_file_path = File.join(uncompressed_file_dir, "installed")

execute "install python ssl module" do
  command "python setup.py install"
  cwd uncompressed_file_dir
  not_if { File.exists?(installed_file_path) }
end

execute "touch #{installed_file_path}" do
  action :run
end

#installing ossec-server 
script "python_install_ossec" do
  interpreter "python"
  user "root"
  cwd "/tmp"
code <<-PYCODE
import pexpect
import sys
child = pexpect.spawn ('/tmp/ossec-hids-2.8.2/install.sh')
child.logfile = sys.stdout
child.expect ('(en/br/cn/de/el/es/fr/hu/it/jp/nl/pl/ru/sr/tr)*?:')
child.sendline ('en')
child.expect ('-- Press ENTER to continue or Ctrl-C to abort. --*')
child.sendline ('')
child.expect ('1- What kind of installation do you want (server, agent, local, hybrid or help)*')
child.sendline ('server')
child.expect ('Choose where to install the OSSEC HIDS*')
child.sendline ('/var/ossec')
child.expect ('3.1- Do you want e-mail notification*')
child.sendline ('n')
child.expect ('3.2- Do you want to run the integrity check daemon*')
child.sendline ('y')
child.expect ('3.3- Do you want to run the rootkit detection engine*')
child.sendline ('y')
child.expect ('- Do you want to enable active response*')
child.sendline ('y')
child.expect ('- Do you want to enable the firewall-drop response*')
child.sendline ('y')
child.expect ('- Do you want to add more IPs to the white list*')
child.sendline ('n')
child.expect ('3.5- Do you want to enable remote syslog (port 514 udp)*')
child.sendline ('y')
child.expect ('--- Press ENTER to continue ---*')
child.sendline ('')
child.expect ('---  Press ENTER to finish (maybe more information below)*')
child.sendline ('')
child.expect(pexpect.EOF)
PYCODE
  not_if {File.exists?("#{Chef::Config[:file_cache_path]}/ossec_lock")}
end
#setting configuration in ossec.conf
cookbook_file '/var/ossec/etc/ossec.conf' do
  source 'ossec.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end


execute "ossecsyslogenable" do
 command "/var/ossec/bin/ossec-control enable client-syslog"
end


execute "ossecrestart" do
 command "/var/ossec/bin/ossec-control restart"
end















