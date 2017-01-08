
# Wait until there are less than MAX_PROCESSES running.
MAX_PROCESSES=250

# Count how many netvision processes are running.
###

function num_processes () {
  echo `ps -e -o comm= | grep generate_class | wc -l`
}

# Count how many class C subnet files there are
# for given class B subnet.
###

function num_classC_files () {
	A=$1
	B=$2
  echo `ls data/$A/$B | wc -l`
}

# Scan class B subnet parallely.
###

function scanB () {
	A=$1
	B=$2

	seq 0 255 | while read C
		do
				until (( `num_processes` < "$MAX_PROCESSES"  ))
				do
					# Sleep for a while in order to give priority to
					# current class B subnet.
					sleep 200
				done
				# Launch process in background in order to finish as
				# soon as possible every class C subnet.
				./generate_classC_JSON.pl $A.$B.$C &
			done

			until (( `num_classC_files $A $B` < 256  ))
			do
				sleep 20
			done
			# Do not launch the process in background, so if it is the
			# last class B subnet, the generation of class A file will
			# find all necessary files.
			./generate_classB_JSON.pl $A.$B
		done
}

# Scan class A subnet parallely.
###

function scanA () {
	A=$1

	seq 0 255 | while read B
		do
			scanB $A $B
		done

		./generate_classA_JSON.pl $A &
}
