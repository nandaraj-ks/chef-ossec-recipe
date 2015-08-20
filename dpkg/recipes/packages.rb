cookbook_file "oneconsole.deb" do
    source "oneconsole.deb"
    owner "root"
    group "root"
    mode "0444"
end
 
#The following did'nt work.
dpkg_package "oneconsole" do
    case node[:platform]
    when "debian","ubuntu"
            package_name "oneconsole"
            source "oneconsole.deb"
    end
    action :install
end
