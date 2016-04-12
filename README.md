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
export USER=myuser
adduser $USER
```

Create public folder

```
mkdir /www
chown $USER /www
```

