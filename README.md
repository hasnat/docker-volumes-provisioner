
# Docker Volumes Provisioner
hub.docker.com [hasnat/volumes-provisioner](https://hub.docker.com/r/hasnat/volumes-provisioner)

An alpine based helper image to essentially make directory
with appropriate owner and permissions to be used by other containers.
This is achieved by [sed](https://linux.die.net/man/1/sed) and [install](https://linux.die.net/man/1/install).

Most images require data folders to be under certain permissions,
for mounted volumes directories have to be created and modified
before container start.
e.g.

- [mysql](https://hub.docker.com/_/mysql) data folder needs to be 1000:1000
- [prometheus](https://hub.docker.com/r/prom/prometheus) needs 65534:65534
- [grafana](https://hub.docker.com/r/grafana/grafana) needs 472:472


### Config
Pass config as env var `PROVISION_DIRECTORIES`

uid:gid:mode:dir(s) e.g. 1000:1000:0755:/var/www

Can contain multiple directories separated by space and/or multiple configs separated by ;

e.g.

- `1000:1000:0755:/var/www/html`
- `1000:1000:0755:/var/www /var/www/html`
- `1000:1000:0755:/var/www /var/www/html;1001:1001:0755:/var/app /var/app/cache`

### draw
```
        PROVISION_DIRECTORIES                                                                              
                                                                                                           
                                                                                                           
                     sed                                                  -d, --directory                  
                                                                          treat all arguments as           
                                                                          directory names; create all      
                                                                          components of the specified      
                           ([0-9]+):([0-9]+):([0-9]+):([^:;]+);?          directories                      
                                │       │       │         │  │                                             
                                │       │       │         │  │            -o, --owner=OWNER                
                                │       │       │         │  │            set ownership (super-user only)  
                                └─────┐ └───┐   └─┐  ┌────┘  └────┐                                        
                                      │     │     │  │            │       -g, --group=GROUP                
                                      │     │     │  │            │       set group ownership, instead of  
                                      │     │     │  │            │       process' current group           
                                      ▼     ▼     ▼  ▼            ▼                                        
                       install -d -o \1 -g \2 -m \3 \4 ; ls -dhn \4 ;     -m, --mode=MODE                  
                                                                          set permission mode (as in       
                                                                          chmod), instead of rwxr-xr-x     
Examples                                                                                                   
                                                                                                           
PROVISION_DIRECTORIES: "1000:1000:0755:/var/www/html"                                                      
PROVISION_DIRECTORIES: "1000:1000:0755:/var/www /var/www/html"                                             
PROVISION_DIRECTORIES: "1000:1000:0755:/var/www /var/www/html;1000:1000:0755:/var/app /var/app/cache"      
PROVISION_DIRECTORIES: "65534:65534:0755:/var/data/prometheus/data"
```

#### Local Run example
```
docker run --rm \
-e PROVISION_DIRECTORIES=1000:1000:0755:/var/www \
-v `pwd`/data:/var/www \
hasnat/volumes-provisioner
ls -dhn data
```

#### Docker Compose prometheus example
Here using depends_on we make sure directory with correct
permissions is created before prometheus starts
```
version: '2'
services:
  volumes-provisioner:
    image: hasnat/volumes-provisioner
    environment:
      PROVISION_DIRECTORIES: "65534:65534:0755:/var/data/prometheus/data"
    volumes:
      - "./var/data:/var/data"
    network_mode: none

  prometheus:
    image: prom/prometheus:v2.3.2
    ports:
      - "9090:9090"
    depends_on:
      - volumes-provisioner
    volumes:
      - "./var/data/prometheus/data:/prometheus/data"

```

#### Build locally
```
docker build -t volumes-provisioner .
docker run --rm \
-e PROVISION_DIRECTORIES=1000:1000:0755:/var/www \
-v `pwd`/data:/var/www \
volumes-provisioner
ls -dhn data
```

#### Notes
Won't work for docker for macos volume mounts

