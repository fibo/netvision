
function scan () {
	A=$1

	# Create data dir first. Every generate_classB_JSON.pl script will
	# try to create it, but since they are launched in parallel,
	# can happen that since they check and it does not exists yet
	# and they create it, another process already did it and an they get
	# an error.
	mkdir -p data/$A

	seq 1 255 | while read B; do echo ./generate_classB_JSON.pl $A.$B & done
}

