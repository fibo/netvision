# netvision

> IPv4 space data visualization

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
mkdir /www
chown $MYUSER /www
```

Configure public folder

```
cat <<EOF > /etc/nginx/ipv4-space.conf
server {
   root /www;
   location / {

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
