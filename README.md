# netvision

> IPv4 space data visualization

## Example

It is required to run as root, cause the `icmp` mode of [Net::Ping](https://metacpan.org/pod/Net::Ping) requires it
and also to have maximum priority when generating the images.

Run a single class C subnet ping, generates a 1.2.3.png

```
generatePNG.pl 1.2.3
```

Run the **BOMB**, ping a whole IPv4 class C subnet, for instance `10.20.*`

```
export A=10
export B=20
seq 0 255 | while read C; do echo $A $B $C; ./generatePNG.pl $A.$B.$C & done &
```

Upload to S3

```
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=YYY123
aws s3 cp 10.20.30.png s3://ip-v4.space/10/20/
```

## Setup

Create an Ubuntu 14 server, then run as root

Install required software

```
apt-get install -y libgd-perl git
```

Get the code

```
cd
git clone https://github.com/fibo/netvision.git
```

