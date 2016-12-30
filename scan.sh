# Perform a traversal scanning. Launching a ping on a whole class A
# subnet, since it can happen no address will respond at all,
# and everything flows better if some address respond, loop over the
# second number of the IP address.

function scan () {
	B=$1

	seq 1 255 | while read A
		do
			./generate_classB_JSON.pl $A.$B &
			# Avoid conflicts among processes, otherwise we get errors like
			# Can't exec "aws": Cannot allocate memory
			# Can't get icmp protocol by name
			sleep 2
		done &

	# Since timeout is set to one second and there are
	# 256 * 256 = 65536
	# IPv4 addresses targeted, and aws cli will do its job, lets...
	sleep 70001
}

