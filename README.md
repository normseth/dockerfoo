<!-- See Also: Evernote "Docker Orchestration" -->

## Simple Laptop Setup
Install Docker Toolbox

## Multi-Host Demo with Swarm & Compose

Steps
1. Clone github.com:dave-tucker/docker-network-demos.git (The remaining steps require tweaking some names, but basically we're following scripts in this repo.)
1. Add registry container to 'demo-dependencies' host in swarm-local.sh.
1. Launch dependency host and registry container.
1. Pull containers needed for demo from Docker Hub (including consul).
  ```
  for i in 'progrium/consul' 'mongo' 'bfirsh/compose-mongodb-demo' ; do
    docker pull $i
  done
  ```
1. Tag and push them into local registry.
  ```
  docker tag progrium/consul localhost:5000/consul
  docker tag mongo localhost:5000/mongodb
  docker tag bfirsh/compose-mongodb-demo localhost:5000/mh-demo-web

  docker push localhost:5000/consul
  docker push localhost:5000/mongodb
  docker push localhost:5000/mh-demo-web
  ```

1. Launch consul container.
1. Launch demo hosts as a Swarm cluster.
<!-- 1. Update web demo yaml file to pull from local registry.  Need to set up registry with TLS for this.  See https://github.com/docker/distribution/blob/master/docs/deploying.md -->
1. Increase the disk allocation in the yaml file (bombs out due to space, otherwise (I doubled it)).
1. Point your docker client to the swarm 'machine': ```eval "$(docker-machine env demo01)"```
1. Build the demo:
  ```
  docker-compose --file counter/docker-compose.yml --x-networking --x-network-driver overlay up -d
  ```
1. Test it out: ```curl http://`docker-machine ip demo01` ```

## Things that might be confusing
* Port publishing: the web container publishes 80:5000, and you can't hit it on 80 without that line.
  Publishing is HOST_PORT:CONTAINER_PORT.
  Need to remember that when using CLI, I'm accessing a service running in a container running in a VM.
  So from my perspective, I need to hit HOST_IP:HOST_PORT, and HOST_IP isn't localhost.

* I have two containers trying to publish port 5000.  Aren't they going to conflict?   
  No, because they are on different VM hosts.

* How does the web container know the location of the mongo container?

## Adding a Private Registry
