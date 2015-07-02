remote_file "/tmp/ossec-hids-2.8.2.tar.gz" do
 source "http://www.ossec.net/files/ossec-hids-2.8.2.tar.gz"
 mode 0644
end
execute 'ossec-hids-2.8.2' do
	command 'tar xzvf ossec-hids-2.8.2.tar.gz'
	cwd '/tmp'
end

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

cookbook_file '/var/ossec/etc/ossec.conf' do
  source 'ossec.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end






