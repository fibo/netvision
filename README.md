# netvision

> IPv4 space data visualization

* [Usage](#usage)
  * [Class C](#class-c)
  * [Class B](#class-b)
  * [Class A](#class-a)
  * [The Internet](#the-internet)
* [Setup](#setup)
  * [Server](#server)
  * [S3](#s3)
* [Data structure](#data-structure)
* [References](#references)

Every website you visit is associated to at least one IP address.

The IPv4 space is composed aproximately by `256 * 256 * 256 * 256` addresses, some of them are private or reserved.

IPv4 addresses will be replaced gradually with IPv6 addresses.
IPv6 was introduced in 2004 on [Root nameservers][Root_nameservers]
but only in 2008 [ICANN] started to use it. In 2011 the [IANA] assigned
the last IPv4 blocks and the protocol will be used until 2025.

Scanning the whole IPv4 space is not that easy, but IPv6 will be huge and
out of the scope of this project. Furthermore, the shape of IPv4 is more
attractive in my opinion, it is easier to explain and with some effort
could be printed.

Internet is divided among 5 world regions each ruled by a [registry][Regional_Internet_registry].

![Internet world regions](https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Regional_Internet_Registries_world_map.svg/1600px-Regional_Internet_Registries_world_map.svg.png)

## Usage

The scripts must be launched by **root**, as required by the [Net::Ping][Perl_Net_Ping] `icmp` mode.

### Class C

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

### Class B

Ping an IPc4 class B subnet. See [how to use GNU screen][screen_how_to] rather
than crontab, nohup or other techniques.

```bash
./generate_classB_JSON.pl 1.2
```

It generates file *data/1/1.2.json* and upload it to S3 bucket **s3://ip-v4.space**.
If the file already exists locally or on S3, it will exit.
This behaviour can be controlled with the `OVERWRITE` environment variable.

```bash
export OVERWRITE=1
./generate_classB_JSON.pl 1.2
```

### Class A

Ping a whole IPv4 class A subnet, for instance `16.*`

```bash
./generate_classA_JSON 16
```

### The Internet

In order to scan the whole IPv4 space with cheap resources in aproximately 45 days
I distributed the job on 4 server workers, each has its own *workerN.sh*
batch script.

For instance, connect to first worker via ssh. Then open a *screen* session
and launch first worker script.

```bash
nohup ./worker1.sh &
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

Set your environment to enable upload to S3

```bash
export AWS_ACCESS_KEY_ID=***
export AWS_SECRET_ACCESS_KEY=***
export AWS_DEFAULT_REGION=us-east-1
```

Optionally, add it to the *~/.bashrc*.

### Sync

Label each host as *workerN*, where *workerN* should sync data from *worker[N+1]* cyclically.

Add to your .bashrc

```bash
export PS1="workerN# "
export NEXT_WORKER=1.2.3.4
export SSH_PORT=XX

function sync_data () {
    rsync -avz -e "ssh -p $SSH_PORT" $NEXT_WORKER:/root/netvision/data/$1 /root/netvision/data/$1
}
```

where

* `PS1` is set to current worker, for example N could be 1.
* XX is the ssh port, other than 22 for security reasons.
* `NEXT_WORKER` is the IP address of the next worker in the chain.

Create an ssh key

```bash
ssh-keygen
```

And copy it to the next worker

```bash
ssh-copy-id -p $SSH_PORT -i ~/.ssh/id_rsa $NEXT_WORKER
```

Now if you want to sync all data launch

```bash
sync_data
```

To sync only a subfolder, pass it as argument

```bash
sync_data 10/235
```

## Data structure

### Class C

* subnet: `{String}` e.g. *10.20.30*.
* ping: can be
  * `{Array}` with lentght 254, filled with 1 or 0 according if host is alive or not.
  * `{Number}` 0 if no host alive was found, 1 if all hosts were alive.

## References

* [IPv4 subnetting reference][IPv4_subnets]
* [Reserved IP addresses][Reserved_IP_addresses]
* [Regional Internet registry][Regional_Internet_registry]
* [List of assigned /8 IPv4 address blocks][Assigned_IPv4_addresses]

[Assigned_IPv4_addresses]: https://en.wikipedia.org/wiki/List_of_assigned_/8_IPv4_address_blocks
[IANA]: https://en.wikipedia.org/wiki/Internet_Assigned_Numbers_Authority
[ICANN]: https://en.wikipedia.org/wiki/ICANN
[IPv4_subnets]: https://en.wikipedia.org/wiki/IPv4_subnetting_reference
[Perl_Net_Ping]: https://metacpan.org/pod/Net::Ping
[Regional_Internet_registry]: https://en.wikipedia.org/wiki/Regional_Internet_registry
[Reserved_IP_addresses]: https://en.wikipedia.org/wiki/Reserved_IP_addresses
[Root_nameservers]: https://en.wikipedia.org/wiki/Root_name_server
[S3_public]: http://g14n.info/2016/04/s3-bucket-public-by-default
[screen_how_to]: http://g14n.info/2015/05/gnu-screen
