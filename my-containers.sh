Plex_Media_Container ()
{
mkdir -pv /data/plex/{config,tvshows,movies} && \
docker run -d \
  --name=plex \
  --network=host \
  -e PUID="`id -u`" \
  -e PGID="`id -g`" \
  -e VERSION=docker \
  -v /data/plex/config:/config \
  -v /data/plex/tvshows/:/tv \
  -v /data/plex/movies:/movies \
  --restart unless-stopped \
  ghcr.io/linuxserver/plex:latest
}


func_Nginx_Webserver_Container ()
{
mkdir -pv /data/nginx/{html,conf.d} && \
echo "Hello Bro" > /data/nginx/html/index.html && \
docker run -d \
  --name=nginx \
  -p 80:80 \
  -v /data/nginx/html:/usr/share/nginx/html \
  #-v /data/nginx/conf.d:/etc/nginx/conf.d \
  --restart unless-stopped \
  nginx:latest
}


func_Torrent_Manager_Container ()
{
mkdir -pv /data/transmission/{config,download,watch}
docker run -d \
  --name=transmission \
  -e PUID="`id -u`" \
  -e PGID="`id -g`" \
  -e TZ=Etc/UTC \
  -e USER=kulit `#optional` \
  -e PASS=143kulit `#optional` \
  -e WHITELIST= `#optional` \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v /data/transmission/config:/config \
  -v /data/transmission/download:/downloads \
  -v /data/transmission/watch:/watch \
  --restart unless-stopped \
  ghcr.io/linuxserver/transmission
}


func_Rsyslog_Server_Container ()
{
mkdir -pv /data/rsyslog/{log,rsyslog.d}
cp conf/rsyslog.conf /data/rsyslog/
docker run -d \
  --name rsyslog \
  --net=host \
  -v /data/rsyslog/log:/var/log \
  -v /data/rsyslog/rsyslog.d:/etc/rsyslog.d \
  --restart unless-stopped \
  rsyslog
}


func_Home_Assistant_Container ()
{
mkdir -pv /data/homeassistant
docker run -d \
  --name homeassistant \
  --network=host \
  --restart unless-stopped \
  --privileged \
  -e TZ=Asia/Singapore \
  -v /data/homeassistant \
  --restart=unless-stopped \
  ghcr.io/home-assistant/home-assistant:stable
}


func_Matter_Server_Container ()
{
mkdir -pv /data/matter_server
docker run -d \
  --name matter \
  --network=host \
  --restart unless-stopped \
  --security-opt apparmor=unconfined \
  -e TZ=Asia/Singapore \
  -v /data/matter_server \
  --restart=unless-stopped \
  ghcr.io/home-assistant-libs/python-matter-server:stable
}


func_Omada_Controller ()
{
mkdir -pv /data/OmadaController/{data,work}
docker run -d \
  --name omada-controller \
  --net=host \
  -e TZ=Asia/Singapore \
  -e SMALL_FILES=false \
  -v /data/OmadaController/data:/opt/tplink/EAPController/data \
  -v /data/OmadaController/work:/opt/tplink/EAPController/work \
  --restart unless-stopped \
  mbentley/omada-controller:latest
}

  case $1 in
    Plex_Media_Container) func_Plex_Media_Container;;
    Nginx_Webserver_Container) func_Nginx_Webserver_Container;;
    Torrent_Manager_Container) func_Torrent_Manager_Container;;
    Rsyslog_Server_Container) func_Rsyslog_Server_Container;;
    Home_Assistant_Container) func_Home_Assistant_Container;;
    Rsyslog_Server_Container) func_Rsyslog_Server_Container;;
    Home_Assistant_Container) func_Home_Assistant_Container;;
    Matter_Server_Container) func_Matter_Server_Container;;
    Omada_Controller) func_Omada_Controller;;
    list) cat $0 | grep "^func_" | sed 's/^func_//;s/ ()//';;
    *) echo "Requires valid parameter";;
  esac
