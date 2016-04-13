# netvision

> IPv4 space data visualization

## Example

It is required to run as root, cause the `icmp` mode of [Net::Ping](https://metacpan.org/pod/Net::Ping) requires it
and also to have maximum priority when generating the images.

Run a single class C subnet ping, generates a 1.2.3.png

```
generatePNG.pl 1.2.3
```

Generate /www/images/1/2/3/1.2.3.png

```
export IPV4SPACE_PUBLIC_DIR=/www
generatePNG.pl 1.2.3
```

Run the **BOMB**, ping all IPv4 space

```
seq 1 254 | while read A; do seq 1 254 | while read B; do seq 1 254 | while read C; do ./generatePNG.pl $A.$B.$C & done; done; done &
```

## Setup

Create an Ubuntu 14 server, then run as root

Install required software

```
apt-get install -y libgd-perl nginx git
```

Create public folder

```
export IPV4SPACE_PUBLIC_DIR=/www
```

Configure public folder

```
cat <<EOF > /etc/nginx/ipv4-space.conf
server {
    listen 80;
    server_name www.ip-v4.space;
    root $IPV4SPACE_PUBLIC_DIR/;
    location /images {
        autoindex on;
    }
}
EOF
```

Get the code

```
cd
git clone https://github.com/fibo/netvision.git
```

Init crontab

```
# TODO
```
