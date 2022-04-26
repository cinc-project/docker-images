source /etc/os-release

if [[ $CPE_NAME =~ enterprise_linux:7 ]] ; then
  cat << EOF > /etc/yum.repos.d/rhel.repo
[rhel7-base]
name=rhel7 base
baseurl=http://148.100.42.7/7Server/\$basearch/os
enabled=1
gpgcheck=0

[rhel7-devtools]
name=rhel7 devtools
baseurl=http://148.100.42.7/7Server/\$basearch/devtools
enabled=1
gpgcheck=0

[rhel7-extras]
name=rhel7 extras
baseurl=http://148.100.42.7/7Server/\$basearch/extras
enabled=1
gpgcheck=0

[rhel7-optional]
name=rhel7 optional
baseurl=http://148.100.42.7/7Server/\$basearch/optional
enabled=1
gpgcheck=0

[rhel7-supplementary]
name=rhel7 supplementary
baseurl=http://148.100.42.7/7Server/\$basearch/supplementary
enabled=1
gpgcheck=0
EOF
else
  cat << EOF > /etc/yum.repos.d/rhel.repo
[rhel8-base]
name=rhel8 base
baseurl=http://148.100.42.7/8/\$basearch/os
enabled=1
gpgcheck=0
[rhel8-supp]
name=rhel8 supp
baseurl=http://148.100.42.7/8/\$basearch/supplementary
enabled=1
gpgcheck=0
[rhel8-appstream]
name=rhel8 appstream
baseurl=http://148.100.42.7/8/\$basearch/appstream
enabled=1
gpgcheck=0
[rhel8-codeready]
name=rhel8 codeready
baseurl=http://148.100.42.7/8/\$basearch/codeready
enabled=1
gpgcheck=0
EOF
fi
