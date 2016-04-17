# netvision

> IPv4 space data visualization

## Usage

The *generate_16x16_PNG.pl* script must be laucnhed by **root**, as required by
the [Net::Ping][Perl_Net_Ping] `icmp` mode.

Run a single class C subnet ping, generates file *data/1/2/1.2.3.json*

```bash
./generate_classC_JSON.pl 1.2.3
```

Enable timing feedback

```bash
$ sudo TIMING=1 ./generate_classC_JSON.pl 1.2.3
Subnet 1.2.3 ping in 115 seconds.
```

Enable verbose output (implies TIMING)

```bash
$ VERBOSE=1 ./generate_classC_JSON.pl 1.2.3
ICMP ping of subnet 1.2.3.* with 1 sec. timeout
Address 1.2.3.1 is alive
Address 1.2.3.2 is alive
...
Subnet 1.2.3 ping in 115 seconds.
```

I am using 1 second timeout on an Ubuntu 14 server with

* 2 Intel(R) Xeon(R) L5520 @ 2.27GHz CPUs
* 2 GB RAM
* 4533.49 bogomips

Of course the *perl* interpreter should finish its job in no more than 5 minutes (> 255 sec.).
Execution time is faster when all hosts respond to ping. For instance, pinging
`172.217.1.*` takes 10 seconds.

Ping an IPc4 class B subnet. See [how to use GNU screen][screen_how_to] rather
than crontab, nohup or other techniques.

```bash
./generate_classB_JSON.pl 1.2
```

Ping a whole IPv4 class A subnet, for instance `10.*`

```bash
export A=10
export TIMING=1
seq 1 254 | while read B; do ./generate_classB_JSON.pl $A.$B & done &
```

Upload to S3

```bash
export AWS_ACCESS_KEY_ID=***
export AWS_SECRET_ACCESS_KEY=***
export AWS_DEFAULT_REGION=us-east-1
aws s3 sync data/ s3://ip-v4.space/data/
```

## Setup

### Server

On an Ubuntu 14 server, install required software

```bash
apt-get install -y awscli git
```

Get the code

```bash
cd
git clone https://github.com/fibo/netvision.git
```

### S3

See how to make an [S3 bucket public by default][S3_public].

## References

* [IPv4 subnetting reference][IPv4_subnets]

[IPv4_subnets]: https://en.wikipedia.org/wiki/IPv4_subnetting_reference
[Perl_Net_Ping]: https://metacpan.org/pod/Net::Ping
[S3_public]: http://g14n.info/2016/04/s3-bucket-public-by-default
[screen_how_to]: http://g14n.info/2015/05/gnu-screen
