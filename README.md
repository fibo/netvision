# netvision

> IPv4 space data visualization

## Usage

The *generate_16x16_PNG.pl* script must be laucnhed by **root**, as required by
the [Net::Ping][Perl_Net_Ping] `icmp` mode.

Run a single class C subnet ping, generates file *data/1/2/1.2.3.json*

```bash
./generate_classC_JSON.pl 1.2.3
```

Enable verbose output

```bash
VERBOSE=1 ./generate_classC_JSON.pl 1.2.3
```

I am using 1 second timeout on an Ubuntu 14 server with

* 2 Intel(R) Xeon(R) L5520 @ 2.27GHz CPUs
* 2 GB RAM
* 4533.49 bogomips

Of course the *perl* interpreter takes no more than 5 minutes (> 255 sec.) and
the execution time is lower depending on how many hosts are *alive*.

Execution time is faster when all hosts respond to ping. For instance, pinging
`172.217.1.*` takes 10 seconds.

Upload to S3

```bash
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=YYY123
export AWS_DEFAULT_REGION=us-east-1
aws s3 sync data/ s3://ip-v4.space/data/
```

Run the **BOMB**, ping a whole IPv4 class A subnet, for instance `10.*`

```bash
export A=10
export VERBOSE=1
seq 1 254 | while read B; do ./generate_classB_JSON.pl $A.$B & done &
```

## Setup

On an Ubuntu 14 server, install required software

```bash
apt-get install -y awscli git
```

Get the code

```bash
cd
git clone https://github.com/fibo/netvision.git
```

## References

* [IPv4 subnetting reference][IPv4_subnets]

[IPv4_subnets]: https://en.wikipedia.org/wiki/IPv4_subnetting_reference
[Perl_Net_Ping]: https://metacpan.org/pod/Net::Ping
