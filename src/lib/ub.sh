#!/bin/sh

echo "
echo 'Starting POST INSTALL' >> /post_install.log 
wget 'https://kickstart.crazyzone.be/lib/el7_ub.sh' -O /tmp/post-install.sh
echo 'unlink /etc/rc2.d/S099.post-install.sh' >> /tmp/post-install.sh
/bin/bash /tmp/post-install.sh | tee ~/post-install.log
" > /target/boot/post-install.sh

ln -s /target/boot/post-install.sh /target/etc/rc2.d/S99.post-install.sh