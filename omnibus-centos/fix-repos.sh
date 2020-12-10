# Use OSL for repos
if [ -f /etc/yum.repos.d/CentOS-Linux-AppStream.repo ] ; then
  # EL8
  BASE="Linux-BaseOS"
  sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-Linux-AppStream.repo
  sed -i -e 's/^#baseurl=.*$contentdir\/$releasever\/AppStream\/$basearch\/os\//baseurl=http:\/\/centos.osuosl.org\/$releasever\/AppStream\/$basearch\/os\//g' /etc/yum.repos.d/CentOS-Linux-AppStream.repo
elif [ -n "$(grep "CentOS release 6" /etc/redhat-release)" ] ; then
  # EL6 is EOL, so use vault
  sed -i -e 's/^#baseurl=.*$releasever\/os\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/os\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^#baseurl=.*$releasever\/updates\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/updates\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^#baseurl=.*$releasever\/addons\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/addons\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^#baseurl=.*$releasever\/extras\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/extras\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^#baseurl=.*$releasever\/centosplus\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/centosplus\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^#baseurl=.*$releasever\/contrib\/$basearch\//baseurl=http\:\/\/vault.centos.org\/6.10\/contrib\/$basearch\//g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-Base.repo
  exit
else
  # EL7
  BASE="Base"
fi

sed -i -e 's/^\(mirrorlist.*\)/#\1/g' /etc/yum.repos.d/CentOS-${BASE}.repo

if [ "$(uname -m)" == "x86_64" ] ; then
  sed -i -e 's/^#baseurl=.*$releasever\/os\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/os\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/updates\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/updates\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/addons\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/addons\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/extras\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/extras\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/centosplus\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/centosplus\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/contrib\/$basearch\//baseurl=http\:\/\/centos.osuosl.org\/$releasever\/contrib\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
else
  sed -i -e 's/^#baseurl=.*$releasever\/os\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/os\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/updates\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/updates\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/addons\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/addons\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/extras\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/extras\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/centosplus\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/centosplus\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
  sed -i -e 's/^#baseurl=.*$releasever\/contrib\/$basearch\//baseurl=http\:\/\/centos-altarch.osuosl.org\/$releasever\/contrib\/$basearch\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
fi
sed -i -e 's/^#baseurl=.*$contentdir\/$releasever\/BaseOS\/$basearch\/os\//baseurl=http:\/\/centos.osuosl.org\/$releasever\/BaseOS\/$basearch\/os\//g' /etc/yum.repos.d/CentOS-${BASE}.repo
