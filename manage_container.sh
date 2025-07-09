PARENT_DIR="/data"

func_Plex_Media ()
{
echo "Creating $1 container"
sudo mkdir -pv $PARENT_DIR/$1
sudo mkdir -pv $PARENT_DIR/$1/config $PARENT_DIR/$1/tvshows $PARENT_DIR/$1/movies $PARENT_DIR/$1/videos $PARENT_DIR/$1/pictures && \
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && (chmod -R 775 $PARENT_DIR/$1; chmod -R 777 $PARENT_DIR/$1/tvshows $PARENT_DIR/$1/movies $PARENT_DIR/$1/videos $PARENT_DIR/$1/pictures) && \
docker run -d \
  --name=$1 \
  --network=host \
  -e PUID="`id -u`" \
  -e PGID="`id -g`" \
  -e VERSION=docker \
  -v $PARENT_DIR/$1/config:/config \
  -v $PARENT_DIR/$1/tvshows/:/tv \
  -v $PARENT_DIR/$1/movies:/movies \
  -v $PARENT_DIR/$1/videos:/videos \
  -v $PARENT_DIR/$1/pictures:/pictures \
  --restart unless-stopped \
  ghcr.io/linuxserver/plex:latest
}


func_Nginx_Webserver ()
{
echo "Creating $1 container"
sudo mkdir -p $PARENT_DIR/$1
sudo mkdir -pv $PARENT_DIR/$1/html $PARENT_DIR/$1/conf.d && \
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && chmod -R 775 $PARENT_DIR/$1 && \
echo "Hello Bro" > $PARENT_DIR/$1/html/index.html && \
docker run -d \
  --name=$1 \
  -p 80:80 \
  -v $PARENT_DIR/$1/html:/usr/share/nginx/html \
  --restart unless-stopped \
  nginx:latest
}


func_Torrent_Manager ()
{
echo "Creating $1 container"
sudo mkdir -pv $PARENT_DIR/$1
sudo mkdir -pv $PARENT_DIR/$1/config $PARENT_DIR/$1/download $PARENT_DIR/$1/watch
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && chmod -R 775 $PARENT_DIR/$1 && \
docker run -d \
  --name=$1 \
  -e PUID="`id -u`" \
  -e PGID="`id -g`" \
  -e TZ=Etc/UTC \
  -e USER=kulit `#optional` \
  -e PASS=143kulit `#optional` \
  -e WHITELIST= `#optional` \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v $PARENT_DIR/$1/config:/config \
  -v $PARENT_DIR/$1/download:/downloads \
  -v $PARENT_DIR/$1/watch:/watch \
  --restart unless-stopped \
  ghcr.io/linuxserver/transmission:latest
}


func_Rsyslog_Server ()
{
sudo mkdir -pv /data/rsyslog/{log,rsyslog.d}
sudo cp conf/rsyslog.conf /data/rsyslog/
docker run -d \
  --name=$1 \
  --net=host \
  -v /data/rsyslog/log:/var/log \
  -v /data/rsyslog/rsyslog.d:/etc/rsyslog.d \
  --restart unless-stopped \
  rsyslog
}


func_Home_Assistant ()
{
echo "Creating $1 container"
sudo mkdir -pv $PARENT_DIR/$1
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && chmod -R 775 $PARENT_DIR/$1 && \
docker run -d \
  --name=$1 \
  --network=host \
  --restart unless-stopped \
  --privileged \
  -e TZ=Asia/Singapore \
  -v $PARENT_DIR/$1 \
  --restart=unless-stopped \
  ghcr.io/home-assistant/home-assistant:latest
}


func_Matter_Server ()
{
echo "Creating $1 container"
sudo mkdir -pv $PARENT_DIR/$1
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && chmod -R 775 $PARENT_DIR/$1 && \
docker run -d \
  --name=$1 \
  --network=host \
  --restart unless-stopped \
  --security-opt apparmor=unconfined \
  -e TZ=Asia/Singapore \
  -v  $PARENT_DIR/$1\
  --restart=unless-stopped \
  ghcr.io/home-assistant-libs/python-matter-server:stable
}


func_Omada_Controller ()
{
echo "Creating $1 container"
sudo mkdir -pv $PARENT_DIR/$1
sudo mkdir -pv $PARENT_DIR/$1/data $PARENT_DIR/$1/work
sudo chown -R `id -u`:`id -u` $PARENT_DIR/$1 && chmod -R 775 $PARENT_DIR/$1 && \
docker run -d \
  --name=$1 \
  --net=host \
  -e TZ=Asia/Singapore \
  -e SMALL_FILES=false \
  -v $PARENT_DIR/$1/data:/opt/tplink/EAPController/data \
  -v $PARENT_DIR/$1/work:/opt/tplink/EAPController/work \
  --restart unless-stopped \
  mbentley/omada-controller:latest
}

func_Update_Container ()
{
  for x in `docker image ls | grep -v REPOSITORY | awk '{print $1}'`;
  do
    echo "Updating Image: $x"
    docker pull ${x}:latest
  done
  echo
  for x in `docker ps --format '{{.Names}}'`
  do
    echo "Restarting Container: $x"
    docker stop ${x}
    docker rm ${x}
    func_$x $x
  done
  echo

  echo "Cleaning up old images..."
  docker image prune -f
}

  case $1 in
    Plex_Media) func_Plex_Media $1;;
    Nginx_Webserver) func_Nginx_Webserver $1;;
    Torrent_Manager) func_Torrent_Manager $1;;
    Rsyslog_Server) func_Rsyslog_Server $1;;
    Home_Assistant) func_Home_Assistant $1;;
#    Rsyslog_Server) func_Rsyslog_Server $1;;
    Home_Assistant) func_Home_Assistant $1;;
    Matter_Server) func_Matter_Server $1;;
    Omada_Controller) func_Omada_Controller $1;;
    update) func_Update_Container;; 
    list) cat $0 | grep "^func_" | sed 's/^func_//;s/ ()//';;
    *) echo "Requires valid parameter";;
  esac
