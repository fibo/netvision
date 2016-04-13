# netvision

> IPv4 space data visualization

## Example

```
generatePNG.pl 1.2.3
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
