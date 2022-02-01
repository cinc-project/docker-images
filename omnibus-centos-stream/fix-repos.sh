# Use OSL for repos
BASE="Stream-BaseOS"
sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-Stream-AppStream.repo
sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-Stream-Extras.repo
sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-${BASE}.repo
sed -i -e 's/^#baseurl=.*$contentdir\/$stream\/BaseOS\/$basearch\/os\//baseurl=http:\/\/centos.osuosl.org\/$stream\/BaseOS\/$basearch\/os\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
sed -i -e 's/^#baseurl=.*$contentdir\/$stream\/AppStream\/$basearch\/os\//baseurl=http:\/\/centos.osuosl.org\/$stream\/AppStream\/$basearch\/os\//g' /etc/yum.repos.d/CentOS-Stream-AppStream.repo
sed -i -e 's/^#baseurl=.*$contentdir\/$stream\/extras\/$basearch\/os\//baseurl=http:\/\/centos.osuosl.org\/$stream\/extras\/$basearch\/os\//g' /etc/yum.repos.d/CentOS-Stream-Extras.repo
