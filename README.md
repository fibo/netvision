# netvision

> IPv4 space data visualization

## Example

```
pingClassB.pl 1.1
```

## Setup

Create an Ubuntu 14 server, then run as root

Install required software

```
apt-get install -y libgd-perl nginx git
```

Create user

```
export MYUSER=myuser
adduser $MYUSER
```

Create public folder

```
export PUBLIC_DIR=/www
seq 0 255 | while read A; do seq -w 0 255 | while read B; do echo mkdir -p $PUBLIC_DIR/images/$A/$B; done; done
chown -R $MYUSER /www
```

Configure public folder

```
cat <<EOF > /etc/nginx/ipv4-space.conf
server {
    listen 80;
    server_name www.ip-v4.space;
    root $PUBLIC_DIR/;
    location /images {
        autoindex on;
    }
}
EOF
```

Get the code

```
sudo su - $MYUSER
git clone https://github.com/fibo/netvision.git
```

Init crontab

```
# TODO
```
