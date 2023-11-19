echo "Hello from ScriptGin bot! Few questions for you..."
echo -n "Which directory would you like to store all container data? [Default: /data]: "
read cdata_path

if [ -z "$cdata_path" ]; then
  cdata_path="/data"
else
   mkdir -p "$cdata_path" 2> /dev/null
   if [ ! -d "$cdata_path" ]; then
     echo "Oops, unable to handle $cdata_path directory"
     exit 1
   fi
fi

# Creating container subforders
for x in /plex/config /plex/tvshows /plex/movies /nginx/html /nginx/conf.d /rsyslog/log /rsyslog/rsyslog.d /squid/log
do
 mkdir -p $cdata_path$x 2> /dev/null
 if [ $? -ne 0 ]; then
   echo "Oops, unable to handle $cdata_path$x directory"
 fi
done 

# Updating docker compose file
sed "s/:-CDATA_PATH-:/\\$cdata_path/g" docker-compose.yml
