# DEVOPS TOOLS - DOCKER COMPOSE FRAMEWORK

###### _Try not to become a man of success, but rather try to become a man of value._

This pipeline project template is created to support development docker faster.

## Concept

```sh
                      loadbalancer (80,443)
                                |
        --------------------------------------------------
        |                                                |
development_network                            production_network
        |                                                |
        |                                  ---------------------------
        |                                 |                          |
    myapp (80)                      myfront (80)                 myback (80)
 (dev.myapp.com)                   (myfront.com)                (myback.com)
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
    - services/
        - development/                  <-- project / app folder
            - .env                      <-- env file for docker-compose
            - docker-compose.yaml       <-- docker-compose config
        - production/
            - .env
            - docker-compose.yaml
    - loadbalancer/
        - docker-compose.yaml
        - certs/                    
    - start.sh                          <-- ✨Magic ✨
```

## note

you need to add to your `/etc/hosts` to run `sample.local` domain

```sh
127.0.0.1 dev.myapp.com myfront.com myback.com
```

## Installation

```sh
git clone -
cd compose-workdir

./start.sh
```

## What you need to do when

### how to add new environment (develop)

- #### Step 1

    ```sh
    cd compose-framework
    mkdir staging
    cd staging
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
      backend-api:                                  #<-- app name, for e.g: backend-api
        restart: always                              #<-- keep start docker when down / error
        image: "${BACKEND_API_REGISTERY}"            #<-- image registery variable loaded from .env file
        networks:
         - staging                                   #<-- network alias ---------------------------------|
        environment:                                                                                     |
          - VIRTUAL_HOST="api.mycompany.com"         #<-- app domain alias (http://api.mycompany.com)    |
          - VIRTUAL_PORT=80
        expose:
          - 80
    networks:                                        #                                                   |
      staging:                                       #<-- network alias for attach to service -----------|
        name: "staging_network"                      #<-- your network name
    ```

- #### Step 3

    Create `.env` file

    ```sh
    nano .env
    ```

    `.env` :

    ```sh
    BACKEND_API_REGISTERY=nginx:alpine
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
    

- #### Step 6

    add network to loadbalancer `docker-compose.yaml` :

    ```sh
    version: '3.7'

    services:
        nginx-proxy:
            restart: always
            image: nginxproxy/nginx-proxy
            volumes:
                - "./certs:/etc/nginx/certs"
            ports:
                - 80:80
                - 443:443
            volumes:
                - /var/run/docker.sock:/tmp/docker.sock:ro
            networks:
                - development
                - production
                - staging                   #<---- add this alias network

    networks:
    production:
        name: "production_network"
    development:                                #<---- alias network
        name: "development_network"             #<---- network name
    staging:
        name: "staging_network"
    ```

- #### Step 7

    restart your nginx loadbalancer

    ```sh
    docker-compose up -d
    ```

    (`optional`) add to your local `/etc/hosts`:

    ```sh
    sudo nano /etc/hosts
    echo "127.0.0.1 api.mycompany.com"
    ```

## License

MIT

**Free Software, Hell Yeah!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [docker]: <https://dockert.com>
