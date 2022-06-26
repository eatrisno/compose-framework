# DEVOPS TOOLS - DOCKER COMPOSE FRAMEWORK

###### _Try not to become a man of success, but rather try to become a man of value._

This pipeline project template is created to support development docker faster.

## Concept

```sh
                       reverse proxy (80,443)
                                |
        --------------------------------------------------
        |                                                |
 example_network                                 example2_network
        |                                                |
        |                                  ---------------------------
        |                                 |                          |
    sample (80)                     sample1 (80)                 sample2 (80)
  (sample.local)                   (sample1.local)              (sample2.local)
```

## What you need to start this project

- Server, PC or laptop
- Internet access
- git installed
- little bit of ✨Magic ✨

## What we are using

- [Docker]
- Docker Compose
- Nginx
- Git

## Features

- loadbalancer with nginx alpine
- docker-compose network managed

## Folder Map

```sh
    - example                           <-- project / app folder
        - .env                          <-- env file for docker-compose
        - docker-compose.yaml           <-- docker-compose config
    - example2
        - .env
        - docker-compose.yaml
    - loadbalancer
        - docker-compose.yaml
        - conf.d
            - default.conf              <-- by default redirect 80 to 443
            - default-ssl.conf.disabled <-- ssl (443) domain example
            - sample-local.conf         <-- sample.local domain
            - sample1-local.conf        <-- sample1.local domain
            - sample2-local.conf        <-- sample2.local domain
        - reload.sh                     <------|
    - start.sh                          <-- ✨Magic ✨
```

## note

you need to add to your `/etc/hosts` to run `sample.local` domain

```sh
127.0.0.1 sample.local sample1.local sample2.local
```

## Installation

```sh
git clone git@bitbucket.org:invstr-devops/compose-workdir.git
cd compose-workdir

./start.sh
```

## To reload loadbalancer

```sh
cd loadbalancer
./reload.sh
```

## What you need to do when

### how to add new environment (develop)

- #### Step 1

    ```sh
    cd compose-workdir
    mkdir develop
    cd develop
    ```

- #### Step 2

    Create `docker-compose.yaml` file

    ```sh
    nano docker-compose.yaml
    ```

    `docker-compose.yaml` :

    ```sh
    version: '3.7'

    services:
      backend-api:                          #<-- app name, for e.g: backend-api
        restart: always                     #<-- keep start docker when down / error
        image: "${BACKEND_API_REGISTERY}"   #<-- image registery variable loaded from .env file
        env_file:
         - "${BACKEND_API_ENV}"             #<-- env variable loaded from .env file to system
        networks:
          develop:                          #<-- network alias ---------------------------------|
            aliases:                        #                                                   |
            - "backend-api.develop"         #<-- app domain alias (http://backend-api.develop)  |
    networks:                               #                                                   |
      develop:                              #<-- network alias for attach to service -----------|
        name: "develop_network"             #<-- your network name
    ```

- #### Step 3

    Create `.env` file

    ```sh
    nano .env
    ```

    `.env` :

    ```sh
    BACKEND_API_REGISTERY=nginx:alpine
    BACKEND_API_ENV=/data/config/develop/backend-api.env
    ```

- #### Step 4

    Start service with this command:

    ```sh
    docker-compose up -d backend-api
    ```

    output:

    ```sh
    Creating network "develop_network" with the default driver
    Creating develop_backend-api_1 ... done
    ```

- #### Step 5

    you need to add nginx config e.g: `loadbalancer/conf.d/backend-api.conf`

    ```sh
    cd ../loadbalancer
    nano conf.d/backend-api.conf
    ```

    for http:

    ```nginx
    server {
      listen 80;
      server_name backend-api.develop.local; 
    
      location / {
        proxy_pass http://backend-api.develop;
      }
    
      error_log  /var/log/nginx/backend-api.develop.error.log error;
    }
    ```

    for https :

    you need to edit `certs/server.key` and `certs/server.crt` with valid domain certificate.

    ```nginx
    server {
      listen 443 ssl;
      server_name backend-api.develop.local; 
    
      include /etc/nginx/conf.d/ssl.include;
    
      location / {
        proxy_pass http://backend-api.develop;
      }
    
      error_log  /var/log/nginx/backend-api.develop.error.log error;
    }
    ```

- #### Step 6

    add network to loadbalancer `docker-compose.yaml` :

    ```sh
    version: '3.7'

    services:
        nginx:
            restart: always
            image: nginx:alpine
            volumes:
                - "./conf.d:/etc/nginx/conf.d"
                - "./certs:/etc/nginx/certs"
            ports:
                - 80:80
                - 443:443
            networks:
                - sample
                - develop                   #<---- add this alias network

    networks:
    sample:
        name: "sample_network"
    develop:                                #<---- alias network
        name: "develop_network"             #<---- network name
    ```

- #### Step 7

    restart your nginx loadbalancer

    ```sh
    ./reload.sh
    ```

    (`optional`) add to your local `/etc/hosts`:

    ```sh
    sudo nano /etc/hosts
    echo "127.0.0.1 backend-api.develop.local"
    ```

## License

MIT

**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [docker]: <https://dockert.com>
