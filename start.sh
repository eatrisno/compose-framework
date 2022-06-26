curr=`pwd`

if [ -x "$(command -v docker)" ]; then
    echo "Docker detected"
else
    echo "Install docker"
    apt update -y
    apt install -y docker-compose docker.io
fi

services=(
 "development/myapp"
 "production/myfront"
 "production/myback"
)

echo "=== Services"
for service in "${services[@]}"
do
	environment=$(echo ${service} | cut -d/ -f 1)
	service_name=$(echo ${service} | cut -d/ -f 2)
	cd "${curr}/services/${environment}"
	docker-compose up -d ${service_name}
done

echo "==== Loadbalancer"
cd "${curr}/loadbalancer"
docker-compose up -d
