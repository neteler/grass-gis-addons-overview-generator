# run this in Debian docker container

# are we in Debian?
cat /etc/issue | grep Debian > /dev/null
if [ $? -ne 0 ] ; then
   echo "ERROR: Run this script in Debian docker container! Found:"
   lsb_release -d 2> /dev/null || cat /etc/issue
   exit 1
fi

# mount point set in run_docker.sh:
cd /src
apt install git gfortran wget python3-pip python3-pandas ssh wget -y
pip3 install -r requirements.txt
