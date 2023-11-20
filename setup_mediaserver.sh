## WARNING: Draft / Incomplete / Untested Script

echo
echo "Hello from ScriptGin shell bot!"
echo

# Validating/Installing docker
which docker > /dev/null
if [ $? -ne 0 ]; then
  echo "Installing docker package..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -a -G docker `whoami`
  sudo newgrp docker
fi
which docker > /dev/null
if [ $? -ne 0 ]; then
  echo "Oops: Unable to validate docker service."
  exit 1
fi

# Validating docker user
docker ps > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Oops: `whoami` is not a docker user"
  exit 1
else 
  cdid=`id -u`
fi

echo "Few questions for you..."
echo -n "Which directory would you like to store all container data? [Default: /data]: "
read cdata_path

if [ -z "$cdata_path" ]; then
  cdata_path="/data"
fi

# Creating mediaserver based directory
echo "Based directory is: $cdata_path"
sudo mkdir -p "$cdata_path" 2> /dev/null
if [ ! -d "$cdata_path" ]; then
 echo "Oops: unable to handle $cdata_path directory"
 exit 1
fi
sudo chmod 766 "$cdata_path"
echo

# Creating container subfolders
for x in /plex/config /plex/tvshows /plex/movies /nginx/html /nginx/conf.d /rsyslog/log /rsyslog/rsyslog.d /squid/log
do
 sudo mkdir -p "$cdata_path$x" 2> /dev/null
 sudo chown `whoami` "$cdata_path$x" 2> /dev/null
 if [ $? -ne 0 ]; then
   echo "Oops: unable to handle $cdata_path$x directory"
   exit 1
 fi
 if [ -d "$cdata_path/nginx/html" ]; then
   echo "This page will be updated by crontab every 10mins..." > "$cdata_path/nginx/html/index.html"
   (crontab -l 2> /dev/null | grep -v landscape-sysinfo; echo "*/10 * * * * (echo '<pre>';uname -a; uptime; echo; echo "  `date`";landscape-sysinfo; echo; df -h $cdata_path; echo '</pre>') > $cdata_path/nginx/html/index.html") | crontab -
 fi
done 

# Updating docker compose file
sed -i "s/:-CDID-:/\$cdid/g; s/:-CDATA_PATH-:/\$cdata_path/g" docker-compose.yml
if [ $? -ne 0 ]; then
  echo "Oops: unable to modify docker-compose.yml"
  exit 1
fi

# Downloading and building creaktive nordvpn-proxy image
git clone https://github.com/creaktive/nordvpn-proxy.git
docker build -t nordvpn-proxy nordvpn-proxy
echo

# Setting up and Starting Media server container services
for x in `cat docker-compose.yml | grep container_name | awk -F: '{print $2}' | sed 's/ //g'`
do
  echo "Stopping and Removing Affected Container: $x"
	docker stop ${x}
	docker rm ${x}
  echo
done

for x in `cat docker-compose.yml | grep container_name | awk -F: '{print $2}' | sed 's/ //g'`
do
	echo "Starting Affected Containers: $x"
	docker-compose up -d
  echo
done

# Housekeeping images
echo "Cleaning up old images..."
docker image prune -f


