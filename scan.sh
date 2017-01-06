
# Wait until there are less than MAX_PROCESSES running.
MAX_PROCESSES=250

function num_processes () {
  echo `ps -e -o comm= | grep generate_class | wc -l`
}

#
# Given a class A subnet as parameter:
#
# 1. Loop over every class B subnet
# 2. Try to scan as many as possible in parallel, its class C subnets
#        Consider that other scan could run at the same time, but, if
#        only one scan is running it will finish a whole class B subnet
#        in about five minutes.
# 3. Scan the class B subnet, since all its class C subnet files are
#        already there, it will take few seconds.
# 4. Finally, when all class B subnets are scanned, go for the class A
#        subnet, it will take few time too, cause it is supposed its
#        class B subnet files will be there.
##

function scan () {
	A=$1

	seq 0 255 | while read B
		do
			seq 0 255 | while read C
				do
					until (( `num_processes` < "$MAX_PROCESSES"  ))
					do
						sleep 10
					done

					./generate_classC_JSON.pl $A.$B.$C &
				done

			until (( `num_processes` < "$MAX_PROCESSES"  ))
			do
				sleep 10
			done
			./generate_classB_JSON.pl $A.$B &
			sleep 2
		done

		./generate_classA_JSON.pl $A &
}
