for x in `docker image ls | grep -v REPOSITORY | awk '{print $1}'`;
do
  echo "Updating Image: $x"
  docker pull ${x}:latest
  echo
done

echo

for x in `docker ps --format '{{.Names}}'`
do
  echo "Restarting Container: $x"
  docker stop ${x}
  docker start ${x}
  echo
done

echo

echo "Cleaning up old images..."
docker image prune -f

echo
