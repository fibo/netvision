use strict;
use warnings;
use v5.12;

use Test::More;

use classC;

ok &classC::isReserved('0.1.12');
ok &classC::isReserved('10.2.4');
ok &classC::isReserved('127.0.0');
ok &classC::isReserved('127.2.0');
ok &classC::isReserved('169.254.4');
ok not &classC::isReserved('170.244.4');
ok &classC::isReserved('172.16.4');
ok &classC::isReserved('172.17.4');
ok &classC::isReserved('172.31.4');
ok &classC::isReserved('192.0.0');
ok not &classC::isReserved('192.2.0');
ok not &classC::isReserved('192.10.0');
ok &classC::isReserved('198.18.0');
ok &classC::isReserved('198.19.0');
ok &classC::isReserved('198.51.100');
ok &classC::isReserved('203.0.13');
ok not &classC::isReserved('223.0.1');
ok &classC::isReserved('224.0.1');
ok &classC::isReserved('239.0.1');
ok &classC::isReserved('240.1.0');

done_testing;
