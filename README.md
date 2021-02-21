# Ovpn docker client

How to run a openvpn client with configuration with a ovpn.com account.

Using docker image https://github.com/dperson/openvpn-client.



### How to

Run setup.sh with 4 arguments. This will download configuration, upack it and update config to work in container.

```
sh setup.sh <url-for-ovpn-conf.zip> <username> <password> <path-to-where-store-ovpn-config>
# example
sh setup.sh https://files.ovpn.com/ubuntu_cli/ovpn-gb-london-multihop.zip myuser mypassword ~/docker/openvpn/config
```

Update volyme path in docker-compose.yml.

If your containers need to expose ports (that use the client network), don't do expose them in their services in the compose file. Add the ports in the openvpn service.

If you need to access other containers within a container use the network subnet ip `172.21.0.0` as ip.

For more advace usage checkout link to the docker image above.



### Example

```
version: '3.5'

networks:
  openvpn:
    name: vpn
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.21.0.0/16

services:
  vpn:
    image: dperson/openvpn-client
    container_name: vpn_client
    cap_add:
      - net_admin
    environment:
      TZ: 'Europe/Sctockholm'
    networks:
      openvpn:
        ipv4_address: 172.21.0.10
    sysctls:# This is needed to start openvpn with ovpn configuration. Don't know why.
      - net.ipv6.conf.all.disable_ipv6=0
    tmpfs:
      - /run
      - /tmp
    restart: unless-stopped
    security_opt:
      - label:disable
    stdin_open: true
    tty: true
    volumes:
      - /dev/net:/dev/net:z
      - ~/docker/openvpn/config:/vpn
    command: '-d'
    ports:
      - "80:80" # Ports for nginx service
      - "443:443"
      # Add more ports if you need more

  nginx: # We don't add ports here, we do it in the vpn service
    restart: always
    image: nginx
    container_name: nginx
    network_mode: "service:vpn_client"# Here we connect to the vpn network
```
