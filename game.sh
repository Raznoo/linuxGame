#!/bin/bash

#game variables
num_cols=6
num_rows=6
board=() #a board representing ALL spaces
active_cells=20
active_map=() # array representing legit spaces on the board
EXIT=-1
KEY1=-1
KEY2=-1
KEY3=-1
SPAWN=-1
DEBUG=0


#Registers for passing arguments
STRREG=""
STRREG1=""
INTREG1=-1
INTREG2=-1
ARRREG=()
ARRREG1=()

#Player Status Registers
keyBag=0
indexAt=-1
commands=0

function getSingleCell(){
	RESULT=-1
	case $STRREG in
		"WEST")
		    RESULT=$(($INTREG1 - 1))
		    ;;

		"NORTH")
		    RESULT=$(($INTREG1 - $num_cols))
		    ;;

		"SOUTH")
		    RESULT=$(($INTREG1 + $num_cols))
    		    ;;

		"EAST")
		    RESULT=$(($INTREG1 + 1))
		    ;;
	esac
	STRREG=""
	return $RESULT
}

function getAdjacentCells(){
	ARRREG=()
	NORTH=-2
	SOUTH=-2
	WEST=-2
	EAST=-2
	#check for walls
	if [ $(($INTREG1 - $num_cols)) -le 0 ] #if north wall
	then
		NORTH=-1
	fi
	if [ $(($INTREG1 + $num_cols)) -gt $(($num_cols * $num_rows)) ] #if south wall
	then
		SOUTH=-1
	fi
	if [ $(($INTREG1 % $num_cols)) -eq 1 ] #if west wall
	then
		WEST=-1
	fi
	if [ $(($INTREG1 % $num_cols)) -eq 0 ] #if west wall
	then
		EAST=-1
	fi

	#do rest of population
	if [ $NORTH -eq -2 ]
	then
		STRREG="NORTH"
		getSingleCell
		temp=$?

		if [ ${board[$temp]} -eq -1 ]
		then
			NORTH=-1
		else
			NORTH=$temp
		fi
	fi
        if [ $SOUTH -eq -2 ]
        then
                STRREG="SOUTH"
                getSingleCell
		temp=$?
		if [ ${board[$temp]} -eq -1 ]
		then
			SOUTH=-1
		else
			SOUTH=$temp
		fi
        fi
        if [ $WEST -eq -2 ]
        then
                STRREG="WEST"
                getSingleCell
                temp=$?
		if [ ${board[$temp]} -eq -1 ]
		then
			WEST=-1
		else
			WEST=$temp
		fi
        fi
        if [ $EAST -eq -2 ]
        then
                STRREG="EAST"
                getSingleCell
		temp=$?
                if [ ${board[$temp]} -eq  -1 ]
		then
			EAST=-1
		else
			EAST=$temp
		fi
        fi

	#input values into array
	ARRREG+=($NORTH)
	ARRREG+=($SOUTH)
	ARRREG+=($WEST)
	ARRREG+=($EAST)
	#RESULTS are returned in the form (North South West East)
	#-1 means the cell is not accessible because...
	#	- The cell does not exist (adjacent to wall)
	INTREG1=-1
}
function resetBoard(){
	if [ $KEY1 -ne -1 ]
	then
		board[$KEY1]=1
	fi
	if [ $KEY2 -ne -1 ]
	then 
		board[$KEY2]=2
	fi
	if [ $KEY3 -ne -1 ]
	then
		board[$KEY3]=3
	fi
	board[$SPAWN]=5
	board[$EXIT]=9
	board[$indexAt]=8
}

# -1 == false
# 0  == true
function isValidCell(){
	getAdjacentCells
	for cell in ${ARRREG[@]}
	do
		if [ $cell -eq -1 ]
		then
			continue
		else
			return 0
		fi
	done
	return -1
}
function doMove(){
	RESULT=-1
	INTREG1=$indexAt
	getAdjacentCells
	case $STRREG1 in
		"WEST")
		    if [ ${ARRREG[2]} -ne -1 ]
	 	    then
			board[$indexAt]=0
		    	indexAt=${ARRREG[2]}
			echo Moved West 1 space
		    else
			echo ERROR Illegal move 
		    fi
		    ;;

		"NORTH")
		    if [ ${ARRREG[0]} -ne -1 ]
	 	    then
			board[$indexAt]=0
		    	indexAt=${ARRREG[0]}
			echo Moved North 1 space
		    else
			echo ERROR Illegal move 
		    fi
		    ;;

		"SOUTH")
    		    if [ ${ARRREG[1]} -ne -1 ]
	 	    then
			board[$indexAt]=0
		    	indexAt=${ARRREG[1]}
			echo Moved South 1 space
		    else
			echo ERROR Illegal move 
		    fi
		    ;;

		"EAST")
		    if [ ${ARRREG[3]} -ne -1 ]
	 	    then
			board[$indexAt]=0
		    	indexAt=${ARRREG[3]}
			echo Moved East 1 space
		    else
			echo ERROR Illegal move 
		    fi
		    ;;
	esac
	STRREG1=""
	resetBoard	
	return $RESULT

}

function doRandom(){
	if [ $(($RANDOM % 10)) -eq 1 ] # 1/10 chance of success
	then
		return 1
	fi
	return 0
}

function populateMap(){
	while [ $KEY1 -eq -1 ]
	do
		CTR=0
		for i in $(seq 1 $(($num_rows * $num_cols)))
		do
			if [ ${board[$i]} == 0 ]
			then
				doRandom
				if [ $? -eq 1 ]
				then
					board[$i]=1
					KEY1=$i
					break
				fi	
				((CTR++))
			fi
		done
	done
	while [ $KEY2 -eq -1 ]
	do
		CTR=0
		for i in $(seq 1 $(($num_rows * $num_cols)))
		do
			if [ ${board[$i]} == 0 ]
			then
				doRandom
				if [ $? -eq 1 ]
				then
					board[$i]=2
					KEY2=$i
					break
				fi	
				((CTR++))
			fi
		done
	done
	while [ $KEY3 -eq -1 ]
	do
		CTR=0
		for i in $(seq 1 $(($num_rows * $num_cols)))
		do
			if [ ${board[$i]} == 0 ]
			then
				doRandom
				if [ $? -eq 1 ]
				then
					board[$i]=3
					KEY3=$i
					break
				fi	
				((CTR++))
			fi
		done
	done
	while [ $EXIT -eq -1 ]
	do
		CTR=0
		for i in $(seq 1 $(($num_rows * $num_cols)))
		do
			if [ ${board[$i]} == 0 ]
			then
				doRandom
				if [ $? -eq 1 ]
				then
					board[$i]=9
					EXIT=$i
					break
				fi	
				((CTR++))
			fi
		done
	done	
	while [ $SPAWN -eq -1 ]
	do
		CTR=0
		for i in $(seq 1 $(($num_rows * $num_cols)))
		do
			if [ ${board[$i]} == 0 ]
			then
				doRandom
				if [ $? -eq 1 ]
				then
					board[$i]=5
					SPAWN=$i
					indexAt=$i
					break
				fi	
				((CTR++))
			fi
		done
	done	
}
function enqueueActiveTiles(){
	objective_array=()
	#find random location for objectives
	for i in $(seq 1 4)
	do
		RAND=-1
		killswitch=0
		while [ $killswitch -eq 0 ] #in case of error, redo
		do
			((killswitch++))
			RAND=$((1+ $RANDOM % $(($active_cells - 1)))) # pick a random number from 0 to active_cells - 1 (not inclusive)
			for cell in ${objective_array[@]}
			do
				if [ $RAND -eq $cell ]
				then
					((killswitch--))
					break
				fi
			done

		done
		objective_array+=($RAND)
	done
	#enqueue all tiles
	ARRREG1=()
	ARRREG1+=(5)
	for i in $(seq 1 $(($active_cells - 1)))
	do
		bomb_is_planted=0
		for index in ${!objective_array[@]}
		do
			if [ $i -eq ${objective_array[$index]} ] #if index is supposed to be an objective
			then
				if [ $index -eq 3 ]
				then 
					ARRREG1+=(9)
				else
					ARRREG1+=($(($index + 1)))
				fi
				((bomb_is_planted++))
			fi
		done
		if [ $bomb_is_planted -eq 0 ] #if nothing got placed already
		then
			ARRREG1+=(0)
		fi
	done
}

function makeDebugBoard(){
	blankBoard
	populateMap

}

function randoPop(){
	iterator=1
	#place random spawn
	SPAWN=$(($RANDOM % $(($num_cols * $num_rows))))
	indexAt=$SPAWN
	board[$SPAWN]=${ARRREG1[0]}
	while [ $active_cells -gt 0 ]
	do
		for i in $(seq 1 $(($num_cols * $num_rows))) 
		do
			if [ ${board[$i]} -eq -1 ]
			then
				INTREG1=$i
				isValidCell
				if [ $? -eq 0 ]
				then
					doRandom
					if [ $? -eq 1 ]
					then
						case ${ARRREG1[$iterator]} in
							1)
								KEY1=$i
								;;
							2)	
								KEY2=$i
								;;
							3)
								KEY3=$i
								;;
							9)
								EXIT=$i
								;;
							-1)
								echo here is an error
								;;
							*)
								;;
						esac
						
						board[$i]=${ARRREG1[$iterator]}
						((iterator++))
						((active_cells--))
						break
					fi
				fi
			fi
		done	
	done
}

function printBoard(){
	echo KEY = KEY1 / KEY 2 / KEY3
	echo GO = SPAWN
	echo ME = player
	echo OUT = EXIT
	echo
	OUTPUT2=""
	for j in $(seq 1 $(($num_cols * 5)))
	do
		OUTPUT2+="="
	done
	echo $OUTPUT2

	for i in $(seq 1 $num_rows)
	do
		OUTPUT=""
		for j in $(seq 1 $num_cols)
		do
			offset=$(($i- 1))
			offset=$(($offset * $num_cols))
			offset=$(($offset + $j))
			OUTPUT1=\|
			case "${board[$offset]}" in
				"0")	
					OUTPUT1+="___"
					;;
				"1")
					OUTPUT1+="Key"
					;;
				"2")
					OUTPUT1+="Key"
					;;
				"3")
					OUTPUT1+="Key"
					;;
				"5")
					OUTPUT1+="GO"
					;;
				"8")
					OUTPUT1+="ME"
					;;
				"9")
					OUTPUT1+="OUT"
					;;
				*)
					OUTPUT1+="XXX"
					;;
			esac
			PADDING=`expr "$OUTPUT1" : '.*'`
			PADDING=$((4 - $PADDING))
			for j in $(seq 1 $PADDING)
			do
				OUTPUT1+=" "
			done
			OUTPUT1+=\|
			OUTPUT+=$OUTPUT1
		done
		echo $OUTPUT
		OUTPUT2=""
		for j in $(seq 1 $(($num_cols * 5)))
		do
			OUTPUT2+="="
		done
		echo $OUTPUT2
	done
}

function blankBoard(){
	total_cells=$(($num_cols * $num_rows))
	board=()
	for n in $(seq 1 $((total_cells + 1)))
	do
		board+=(0)
	done
}

function nullBoard(){
	total_cells=$(($num_cols * $num_rows))
	board=()
	for n in $(seq 1 $((total_cells + 1)))
	do
		board+=(-1)
	done
}

function makeBoard(){
	nullBoard
	enqueueActiveTiles
	randoPop

}

# -1 == error in vars
# 0  == is goo
function checkVars(){
	if [ $(($num_cols * $num_rows)) -lt 4 ]
	then
		echo "ERROR Not a large enough board"
		exit 1
	fi
	if [ $active_cells -gt $(($num_cols * $num_rows)) ]
	then
		echo "ERROR Requested more cells than spaces"
		exit 1
	fi
	if [ $active_cells -gt 20 ]
	then
		echo "ERROR Requested too many active cells"
		exit 1
	fi
}
function doHelp(){
	echo
	echo west:   move the player 1 unit west
	echo east:   move the player 1 unit east
	echo north:  move the player 1 unit north
	echo south:  move the player 1 unit south
	echo help:   prints a list of commands
	echo map:    prints a map of the current board
	echo take:   grabs the key in the room
	echo exit:   exits the game
	echo unlock: applies keys to doors in the room
	echo
}
function doTake(){
	if [ $indexAt -eq $KEY1 ]
	then
		KEY1=-1
		echo You have found the first key!
		
		echo The room around you shakes and transforms in front of your eyes...
		((keyBag++))	
	elif [ $indexAt -eq $KEY2 ]
	then
		KEY2=-1
		echo You have found the second key!

		echo The room around you shakes and transforms in front of your eyes...
		((keyBag++))
	elif [ $indexAt -eq $KEY3 ]
	then
		KEY3=-1
		echo You have found the third key!

		echo The room around you shakes and transforms in front of your eyes...
		((keyBag++))
	else
		echo There are no keys in this room!
	fi
}

function doUnlock(){
	if [ $keyBag -eq 3 ]
	then
		if [ $indexAt -eq $EXIT ]
		then
			echo You unlock the door...
			echo YOU WIN!!!!!!!!
			exit 0
		else
			echo The exit is not in this room
		fi
	else
		echo There are more keys to be found!
	fi
}
function printWelcome() {
	echo Welcome to the game!!!
	echo Type \'help\' for a list of commands
}

function dumpVars(){
	echo key1: $KEY1
	echo key2: $KEY2
	echo key3: $KEY3
	echo spawn: $SPAWN
	echo exit: $EXIT
}
function doOverflow(){
        RESULT=$INTREG2
        INTREG2=-1
        roomsCounts=$(ls ./Rooms/ | wc -l)
        roomsCounts=$(($roomsCounts - 5))
        while [ $INTREG2 -gt $roomsCounts ]
        do
                INTREG2=$(($INTREG2 - $roomsCounts))
        done
        return $RESULT
}

function doLook(){
        case $indexAt in
                $KEY1)
                        cat Rooms/0A.txt
			echo "You see the glint of a key"
                        ;;
                $KEY2)
                        cat Rooms/0B.txt
			echo "You can faintly make out the glint of a key"
                        ;;
                $KEY3)
                        cat Rooms/0C.txt
			echo "You see the brilliant sparkling of a key"
                        ;;
                $SPAWN)
                        cat Rooms/0E.txt
                        ;;
                $EXIT)
                        cat Rooms/0D.txt
                        ;;
                *)
                        INTREG2=$indexAt
                        doOverflow
                        cat ./Rooms/$(ls ./Rooms/ | sort | head -$(($? + 5)) | tail -1)
                        ;;
        esac
	echo ""
	echo you have inputted $commands commands and have $keyBag keys
	echo ""
}
function playGame(){
	checkVars
	if [ $DEBUG -eq 1 ]
	then
		makeDebugBoard
	else
		makeBoard
	fi
	resetBoard
	printWelcome
#	dumpVars
	while true
	do
		read INPUT

		((commands++))
		case $INPUT in
			"west")
				STRREG1="WEST"
				doMove
				;;
			"east")
				STRREG1="EAST"
				doMove
				;;
			"north")
				STRREG1="NORTH"
				doMove
				;;
			"look")
				doLook
				;;
			"south")
				STRREG1="SOUTH"
				doMove
				;;
			"map")
				printBoard
				;;
			"unlock")
				doUnlock
				;;
			"take")
				doTake
				;;
			"help")
				doHelp
				;;
			"exit")
				exit 0
				;;
			*)
				echo Illegal input. Type \'help\' for list of commands
				;;		
		esac
	done
}

playGame
