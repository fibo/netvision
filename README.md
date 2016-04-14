# netvision

> IPv4 space data visualization

## Usage

The *generate_16x16_PNG.pl* script must be laucnhed by **root**, as required by
the [Net::Ping][Perl_Net_Ping] `icmp` mode.

Run a single class C subnet ping, generates file *data/1/2/1.2.3.png*

```bash
./generate_16x16_PNG.pl 1.2.3
```

Enable verbose output

```bash
VERBOSE=1 ./generate_16x16_PNG.pl 1.2.3
```

Run the **BOMB**, ping a whole IPv4 class B subnet, for instance `10.20.*`

```bash
export A=10
export B=20
export VERBOSE=1
seq 0 255 | while read C; do echo $A $B $C; ./generate_16x16_PNG.pl $A.$B.$C & done &
```

I am using 1 second timeout on an Ubuntu 14 server with

* 2 Intel(R) Xeon(R) L5520 @ 2.27GHz CPUs
* 2 GB RAM
* 4533.49 bogomips

Of course the *perl* interpreter takes no more than 5 minutes (> 255 sec.) and
the execution time is lower depending on how many hosts are *alive*.

Execution time is faster if it is a populated 
Upload to S3

```bash
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=YYY123
aws s3 sync data/ s3://ip-v4.space/data/
```

## Setup

Create an Ubuntu 14 server, then run as root

Install required software

```bash
apt-get install -y libgd-perl git
```

Get the code

```bash
cd
git clone https://github.com/fibo/netvision.git
```

[Perl_Net_Ping]: https://metacpan.org/pod/Net::Ping
