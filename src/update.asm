#################################
######			   ######
######      UPDATING       ######
######			   ######
#################################

.include "constants.asm"
.include "macros.asm"

.text
.globl UPDATE
UPDATE: 
	push
	
	lw $t0, gameState
	beq $t0, 0, UPDATE_STATE_0
	beq $t0, 1, UPDATE_STATE_1
	beq $t0, 2, UPDATE_STATE_2
	beq $t0, 3, UPDATE_STATE_3
	beq $t0, 4, UPDATE_STATE_4
	beq $t0, 5, UPDATE_STATE_5
	
	j EXIT
	
	UPDATE_STATE_0:
		jal CHECK_FOR_START_BUTTON_PRESS
		j END_UPDATE_STATE
	UPDATE_STATE_1:
		jal UPDATE_GAME
		j END_UPDATE_STATE
	UPDATE_STATE_2:
	UPDATE_STATE_3:
	UPDATE_STATE_4:
	UPDATE_STATE_5:
		jal CHECK_FOR_REPLAY_GAME_BUTTON_PRESS
		j END_UPDATE_STATE
	END_UPDATE_STATE:
	
	return

UPDATE_GAME:
	push
	allocate 2
	
	lw $t0, bluePlayerLivesRemaining
	beq $t0, 0, SKIP_BLUE_INTERACTIONS
		# Handle blue interactions
		li $a0, 0
		jal CHECK_AND_HANDLE_COLLISIONS		# Returns $v0 == 0 if player not on log/turtle, == 1 if on log, == 2 if on turtle
		CHECK_BLUE_COLLISIONS_DONE:		# Break section if blue player dies
		sw $v0, ($sp)
	
	SKIP_BLUE_INTERACTIONS:
			
	lw $t0, pinkPlayerLivesRemaining
	beq $t0, 0, SKIP_PINK_INTERACTIONS
		
		# Handle pink interactions
		li $a0, 1
		jal CHECK_AND_HANDLE_COLLISIONS		# Returns $v0 == 0 if player not on log/turtle, == 1 if on log, == 2 if on turtle
		CHECK_PINK_COLLISIONS_DONE:		# Break section if pink player dies
		sw $v0, 4($sp)
	
	SKIP_PINK_INTERACTIONS:
	
	
	jal CHECK_AND_HANDLE_KEYPRESSES		# Check keypresses for pink and blue
	
	lw $v0, ($sp)
	lw $v1, 4($sp)
	jal UPDATE_NPC_POSITIONS
	
	jal CHECK_IF_PLAYER_IN_END_ZONE
	
	free 2
	return

CHECK_IF_PLAYER_IN_END_ZONE:
	push
	
	# Check blue player
	lw $t0, bluePlayerPosition
	lw $t1, waterRegionStart
	blt $t0, $t1, LESS_THAN_WATER_START_BLUE
	j NOT_IN_END_ZONE_BLUE
	LESS_THAN_WATER_START_BLUE:
		lw $t1, endingRegionStart
		bge $t0, $t1, WITHIN_GOAL_BOUNDS_BLUE
		j NOT_IN_END_ZONE_BLUE
		WITHIN_GOAL_BOUNDS_BLUE:
			la $t0, bluePlayerWon
			li $t1, 1
			sw $t1, ($t0)
	
	NOT_IN_END_ZONE_BLUE:
	
	lw $t0, pinkPlayerPosition
	lw $t1, waterRegionStart
	blt $t0, $t1, LESS_THAN_WATER_START_PINK
	j NOT_IN_END_ZONE_PINK
	LESS_THAN_WATER_START_PINK:
		lw $t1, endingRegionStart
		bge $t0, $t1, WITHIN_GOAL_BOUNDS_PINK
		j NOT_IN_END_ZONE_PINK
		WITHIN_GOAL_BOUNDS_PINK:
			la $t0, pinkPlayerWon
			li $t1, 1
			sw $t1, ($t0)
	
	NOT_IN_END_ZONE_PINK:
	
	### CHECK FOR ENDING STATES
	lw $t0, bluePlayerWon
	lw $t1, pinkPlayerWon
	lw $t2, bluePlayerLivesRemaining
	lw $t3, pinkPlayerLivesRemaining
	
	beq $t0, 1, BLUE_PLAYER_WON
	j BLUE_PLAYER_DIDNT_WIN
	BLUE_PLAYER_WON:
		beq $t1, 1, SET_GAME_STATE_BOTH_WON
		beq $t3, 0, SET_GAME_STATE_BLUE_WON_PINK_LOST
		j NOT_IN_END_STATE
	BLUE_PLAYER_DIDNT_WIN:
		beq $t1, 1, PINK_PLAYER_WON
		j PINK_PLAYER_DIDNT_WIN
		PINK_PLAYER_WON:
			beq $t2, 0, SET_GAME_STATE_PINK_WON_BLUE_LOST
			j NOT_IN_END_STATE
		PINK_PLAYER_DIDNT_WIN:
			beq $t2, 0, BLUE_PLAYER_DIED
			j NOT_IN_END_STATE
			BLUE_PLAYER_DIED:
				beq $t3, 0, SET_GAME_STATE_BOTH_LOST
			j NOT_IN_END_STATE
	NOT_IN_END_STATE:
	
	return

SET_GAME_STATE_BOTH_LOST:
	push
	
	la $t0, gameState
	li $t1, 5
	sw $t1 ($t0)
	
	j main
	
	return

SET_GAME_STATE_PINK_WON_BLUE_LOST:
	push
	
	la $t0, gameState
	li $t1, 3
	sw $t1 ($t0)
	
	j main
	
	return

SET_GAME_STATE_BLUE_WON_PINK_LOST:
	push
	
	la $t0, gameState
	li $t1, 2
	sw $t1 ($t0)
	
	j main
	
	return

SET_GAME_STATE_BOTH_WON:
	push
	
	la $t0, gameState
	li $t1, 4
	sw $t1 ($t0)
	
	j main
	
	return

CHECK_FOR_REPLAY_GAME_BUTTON_PRESS:
	push
	
	# Check for keypress
	lw $t8, 0xffff0000
	beq $t8, 0, USER_SELECTED_REPLAY_DONE
	USER_SELECTED_REPLAY:
		lw $t2, 0xffff0004
		
		bne $t2, 0x72, USER_SELECTED_REPLAY_DONE	# if the user pressed 'r'
			la $t0, gameState
			li $t1, 1
			sw $t1, ($t0)				# Set gameState = 1 meaning start the regular game
			j main
	USER_SELECTED_REPLAY_DONE:
	
	return

CHECK_FOR_START_BUTTON_PRESS:
	push
	
	# Check for keypress
	lw $t8, 0xffff0000
	beq $t8, 0, USER_STARTED_DONE
	USER_STARTED_GAME:
		la $t0, gameState
		li $t1, 1
		sw $t1, ($t0)		# Set gameState = 1 meaning start the regular game
		li $t0, 0
		j START
	USER_STARTED_DONE:
	
	return

# A function to update the positions of all of the NPCs
#	PARAMS
#		$v0 stores the collision status of BLUE frog
#		$v1 stores the collision status of PINK frog
UPDATE_NPC_POSITIONS:
	push
	allocate 2
	
	sw $v0, ($sp)
	sw $v1, 4($sp)
	
	# For each car, update the position and check collision against wall
	li $v0, roadObjectsOfType
	la $a0, carPositionsArray
	li $a1, carVel
	li $a2, carDirection
	la $a3, carVelCounter
	jal UPDATE_SINGLE_TYPE_OF_OBJECT
	
	# For each truck, update the position and check collision against wall
	li $v0, roadObjectsOfType
	la $a0, truckPositionsArray
	li $a1, truckVel
	li $a2, truckDirection
	la $a3, truckVelCounter
	jal UPDATE_SINGLE_TYPE_OF_OBJECT

	# For each log, update the position and check collision against wall
	li $v0, waterObjectsOfType
	la $a0, logPositionsArray
	li $a1,	logVel
	li $a2, logDirection
	la $a3, logVelCounter
	jal UPDATE_SINGLE_TYPE_OF_OBJECT
	
	# CHECK WHETHER THE LOG MOVED ($v1 = 1) AND WHETHER THE PLAYER IS ON A LOG ($v0 = 1)
	beq $v1, 1, LOG_MOVED_CHECK_IF_PLAYER_ON
	j FINISH_LOG_CHECK
	LOG_MOVED_CHECK_IF_PLAYER_ON:
		# Check if blue player was on
		lw $v0, ($sp)					# Load the old $v0 out of stack
		beq $v0, 1, ACTUALLY_MOVE_BLUE_PLAYER_WITH_LOG
		j DONT_MOVE_BLUE_PLAYER_WITH_LOG
		ACTUALLY_MOVE_BLUE_PLAYER_WITH_LOG:
			move $a0, $v0
			li $a1, 0
			jal MOVE_PLAYER_WITH_WATER_VEHICLE
			li $v0, 0
		DONT_MOVE_BLUE_PLAYER_WITH_LOG:
		
		# Check if pink player was on
		lw $v0, 4($sp)					# Load old $v0 out of stack
		beq $v0, 1, ACTUALLY_MOVE_PINK_PLAYER_WITH_LOG
		j DONT_MOVE_PINK_PLAYER_WITH_LOG
		ACTUALLY_MOVE_PINK_PLAYER_WITH_LOG:
			move $a0, $v0
			li $a1, 1
			jal MOVE_PLAYER_WITH_WATER_VEHICLE
			li $v0, 0
		DONT_MOVE_PINK_PLAYER_WITH_LOG:
	FINISH_LOG_CHECK:
	
	# For each turtle, update the position and check collision against wall
	li $v0, waterObjectsOfType
	la $a0, turtlePositionsArray
	li $a1,	turtleVel
	li $a2, turtleDirection
	la $a3, turtleVelCounter
	jal UPDATE_SINGLE_TYPE_OF_OBJECT
	
	# CHECK WHETHER THE TURTLE MOVED ($v1 = 1) AND WHETHER THE PLAYER IS ON A TURTLE ($v0 = 2)
	beq $v1, 1, TURTLE_MOVED_CHECK_IF_PLAYER_ON
	j FINISH_TURTLE_CHECK
	TURTLE_MOVED_CHECK_IF_PLAYER_ON:
		# Check if blue player was on
		lw $v0, ($sp)					# Load the old $v0 out of stack
		beq $v0, 2, ACTUALLY_MOVE_BLUE_PLAYER_WITH_TURTLE
		j DONT_MOVE_BLUE_PLAYER_WITH_TURTLE
		ACTUALLY_MOVE_BLUE_PLAYER_WITH_TURTLE:
			move $a0, $v0
			li $a1, 0
			jal MOVE_PLAYER_WITH_WATER_VEHICLE
			li $v0, 0
		DONT_MOVE_BLUE_PLAYER_WITH_TURTLE:
		
		# Check if pink player was on
		lw $v0, 4($sp)					# Load old $v1 out of stack
		beq $v0, 2, ACTUALLY_MOVE_PINK_PLAYER_WITH_TURTLE
		j DONT_MOVE_PINK_PLAYER_WITH_TURTLE
		ACTUALLY_MOVE_PINK_PLAYER_WITH_TURTLE:
			move $a0, $v0
			li $a1, 1
			jal MOVE_PLAYER_WITH_WATER_VEHICLE
			li $v0, 0
		DONT_MOVE_PINK_PLAYER_WITH_TURTLE:
	FINISH_TURTLE_CHECK:
	
	free 2
	return

# A function to move the player with the water vehicle they are on, if they are on one
#	NOTE:
#		This function assumes that the object the player is on moved this frame
#	PARAMS:
#		$a0 == 0 if player is NOT on a water vehicle
#		$a0 == 1 if player is on a LOG
#		$a0 == 2 if player is on a TURTLE
#		$a1 == 0 if blue frog
#		$a1 == 1 if pink frog
MOVE_PLAYER_WITH_WATER_VEHICLE:
	push
	
	beq $a0, 1, MOVE_PLAYER_WITH_LOG
	beq $a0, 2, MOVE_PLAYER_WITH_TURTLE
	DO_NOT_MOVE_PLAYER_WITH_LOG_OR_TURTLE:
		j MOVE_PLAYER_DECISION_END
	MOVE_PLAYER_WITH_LOG:
		li $t0, tileTimesPixelConversion					# Move a single tile to the right

		j MOVE_PLAYER_WITH_VELOCITY
	MOVE_PLAYER_WITH_TURTLE:
		li $t0, -tileTimesPixelConversion						# Move a single tile to the left
		
		j MOVE_PLAYER_WITH_VELOCITY
	MOVE_PLAYER_WITH_VELOCITY:
		ternary_2args $a1, 0, la, $t8, bluePlayerPosition, pinkPlayerPosition	# Load addr(playerPosition)
		lw $t9, ($t8)								# Load playerPosition
		addu $t9, $t9, $t0							# Move a single pixel to the left
		sw $t9, ($t8)								# Save that position back into the data
		
		j MOVE_PLAYER_DECISION_END
	MOVE_PLAYER_DECISION_END:
	
	return

# A function to iterate through a single type of object and update the positions of all of them
#	PARAMS:
#		$v0 is the VEHICLE maximum (e.g. roadObjectsOfType or waterObjectsOfType)
#		$a0 stores the address of the first element in the positions array (e.g. addr(carPositionsArray[0]))
#		$a1 stores the velocity of the object
#		$a2 is the DIRECTION of the object (-1 for left, 1 for right)
#		$a3 is the address of the velocity counter
#	RETURNS:
#		$v1 == 1 if the object moved this frame
#		$v1 == 0 if the object DIDN'T move this frame
UPDATE_SINGLE_TYPE_OF_OBJECT:
	# $t0 is the loop counter
	# $t1 is UNUSED
	# $t2 becomes is the offset of the car
	# $t3 becomes the position of the car + movement
	# $t4 is the position of the killing-boundary
	# $t5 is the copied $t1 for deleting purposes 
	# $t6 is the position modulo the width
	# $t7 is the amount to add to get a left-dying object back on the right side
	# $t8 is the address of the player's position
	# $t9 is the player's position
	push
	
	lb $t0, ($a3)
	bne $a1, $t0, DO_NOT_MOVE_SINGLE_TYPE_OF_OBJECT 	# If the counter is not at the velocity, don't move
	
	MOVE_SINGLE_TYPE_OF_OBJECT:				# The counter equaled the velocity
	
		li $t0, 0					# The loop counter
		
		FOR_EACH_OBJECT_UPDATE_LOOP:
			beq $t0, $v0, FOR_EACH_OBJECT_UPDATE_LOOP_END
				
			la $t2, ($a0)				# Get the first car's position
			sll $t3, $t0, wordSizeShiftAmt		# $t3 stores the address offset, adjusted for word size
			add $t2, $t2, $t3			# Offset by the loop counter - $t2 stores the address of the current car's position
			lw $t3, ($t2)				# Load current car position
			
			### CHECK WHETHER THE OBJECT SHOULD DIE ###
		
			li $t5, width
			addi $t5, $t5, -1					# Store $t5 = width - 1
			sll $t5, $t5, pixelConversionShiftAmt			# Store $t5 = pixelConversionShiftAmt * (width - 1)
			and $t6, $t3, $t5					# Compute position mod width
			
			beq $a2, 1, RESET_ON_RIGHT				# Check for reset on the right or left
			RESET_ON_LEFT:						# If the object should die on the left
				blt $t6, 3, OBJECT_AT_END_ON_LEFT # Allow 2 pixels on the left buffer-space ### TODO REMOVE MAGIC NUMBER ###
			
				OBJECT_NOT_AT_END_ON_LEFT:			# If the object is in the middle somewhere
					# Move according to direction
					addi $t3, $t3, -tileTimesPixelConversion
					j RESET_END_DECISION
				OBJECT_AT_END_ON_LEFT:				# If the object is at the end on the left
					li $t7, width
					addiu $t7, $t7, -twoTiles		# ### TODO REMOVE MAGIC NUMBER ###
					sll $t7, $t7, pixelConversionShiftAmt
					add $t3, $t3, $t7			# Then add $t7 to position to get it back on the right
					j RESET_END_DECISION

			RESET_ON_RIGHT:						# If the object should die on the right
				li $t4, width
				addiu $t4, $t4, -tileSize				# ### TODO REMOVE MAGIC NUMBER ###
				sll $t4, $t4,  pixelConversionShiftAmt		# $t4 = pixelConversion * (width - magic number)
				bge $t6, $t4, OBJECT_AT_END_ON_RIGHT
				
				
				OBJECT_NOT_AT_END_ON_RIGHT:			# If object is in the middle somewhere
					# Move according to direction
					addi $t3, $t3, tileTimesPixelConversion
					j RESET_END_DECISION
				OBJECT_AT_END_ON_RIGHT:				# If the object is at the end on the right
					sub $t3, $t3, $t6			# Then subtract $t7 to position to get it back to the left
					j RESET_END_DECISION
			RESET_END_DECISION:
			
			sw $t3, ($t2)						# Save that new position back in
		
			addi $t0, $t0, 1					# Increment loop counter
			j FOR_EACH_OBJECT_UPDATE_LOOP
		FOR_EACH_OBJECT_UPDATE_LOOP_END:
			move $t0, $zero
		
		li $t0, velocityResetValue				# Reset the counter back to ONE
		sb $t0, ($a3)						# Save the new velocity counter value (of 1)
		
		li $v1, 1						# Return 1 to tell that we moved
		j MOVE_SINGLE_TYPE_OF_OBJECT_END
	DO_NOT_MOVE_SINGLE_TYPE_OF_OBJECT:				# The counter was NOT equal to the velocity
		addi $t0, $t0, 1					# Increment the velocity counter
		sb $t0, ($a3)						# Save the new velocity counter value
		
		li $v1, 0
		j MOVE_SINGLE_TYPE_OF_OBJECT_END
	MOVE_SINGLE_TYPE_OF_OBJECT_END:

	return

# A function to check and handle the collisions for a single player
#	PARAMS:
#		$a0 stores the flag of the player. $a0 == 0 is BLUE frog. $a0 == 1 is PINK frog
CHECK_AND_HANDLE_COLLISIONS:
	push
	allocate 1
	sw $a0, ($sp)
	
	# These calls overwrite $a0!!!!
	jal CHECK_HIT_ROAD_VEHICLES
	
	lw $a0, ($sp)
	jal CHECK_PLAYER_ON_LOG_OR_TURTLE	# Returns a $v0 = 0 if a player is NOT on a log/turtle, 1 if on LOG, 2 if on TURTLE
	
	beqz $v0, GOTO_CHECK_PLAYER_IN_WATER
	DONT_CHECK_PLAYER_IN_WATER:
		j CHECK_PLAYER_IN_WATER_END
	GOTO_CHECK_PLAYER_IN_WATER:
		lw $a0, ($sp)
		jal CHECK_PLAYER_IN_WATER
		j CHECK_PLAYER_IN_WATER_END
	CHECK_PLAYER_IN_WATER_END:
	
	free 1
	return

# A function for checking if the player is in the water. 
#	NOTES:
#		Assumes that player is NOT on a log/turtle
#	PARAMS:
#		$a0 stores the flag of the player (0 = blue, 1 = pink)
CHECK_PLAYER_IN_WATER:
	push
	
	# Load playerPosition into $t0
	ternary_2args $a0, 0, lw, $t0, bluePlayerPosition, pinkPlayerPosition
	
	lw $t1, safeRegionStart			# Load safe region starting point
	blt $t0, $t1, LESS_THAN_WATER_END
	j NOT_IN_WATER_BOUNDS
	LESS_THAN_WATER_END:
		la $t1, waterRegionStart	# Load the address of the water region starting point
		lw $t1, ($t1)			# Load the water region starting position
		bge $t0, $t1, WITHIN_BOTH_BOUNDS
		j NOT_IN_WATER_BOUNDS
		WITHIN_BOTH_BOUNDS:
			jal PLAYER_DIED
			
			ternary_2args, $a0, 0, la, $t0, CHECK_BLUE_COLLISIONS_DONE, CHECK_PINK_COLLISIONS_DONE
			return
			jr $t0
	NOT_IN_WATER_BOUNDS:
	
	return

# A function to check whether the player is on a water vehicle
#	PARAMS:
#		$a0 == 0 if blue, 1 if pink
#	RETURNS:
#		$v0 == 0 if player was NOT on an object
#		$v0 == 1 if player was on a LOG
#		$v0 == 2 if player was on a TURTLE
CHECK_PLAYER_ON_LOG_OR_TURTLE:
	push
	allocate 1
	
	# Store a local $a0, the player flag
	sw $a0, ($sp)
	
	# Load playerPosition
	lw $a0, ($sp)
	ternary_2args, $a0, 0, lw, $a0, bluePlayerPosition, pinkPlayerPosition
	la $a1, turtlePositionsArray			# Load positions of the turtles 
	jal CHECK_PLAYER_ON_ONE_TYPE_WATER_VEHICLE	# Check if on turtles - returns $v0 == 0 if on TURTLE
	
	beqz $v0, ON_TURTLE
	j NOT_ON_TURTLE
	NOT_ON_TURTLE:					# If not on a log, check turtle collisions
		# Load playerPosition
		lw $a0, ($sp)
		ternary_2args, $a0, 0, lw, $a0, bluePlayerPosition, pinkPlayerPosition
		la $a1, logPositionsArray			# Load positions of the logs 
		jal CHECK_PLAYER_ON_ONE_TYPE_WATER_VEHICLE	# Check if on log - returns $v0 == 0 if on LOG
		
		beqz $v0, ON_LOG				# was on turtle, return 2
		j NOT_ON_ANY_WATER_VEHICLE			# break and return 0
	ON_LOG: 
		li $v0, 1				# return the $v0 = 1
		j MADE_PLAYER_ON_WATER_VEHICLE_DECISION
	ON_TURTLE:
		li $v0, 2				# return the $v0 = 2
		j MADE_PLAYER_ON_WATER_VEHICLE_DECISION
	NOT_ON_ANY_WATER_VEHICLE:
		li $v0, 0				# return the $v0 = 0
		j MADE_PLAYER_ON_WATER_VEHICLE_DECISION
	MADE_PLAYER_ON_WATER_VEHICLE_DECISION:
	
	free 1
	return

# A function to check whether or not the player is on a certain type of water vehicle (log or turtle)
#	PARAMS:
#		$a0 stores the player's position
#		$a1 stores the address of the first element in the vehicle position array (e.g. logPositionsArray)
#	RETURNS:
# 		$v0 == 0 if the player IS on this type of object, and 1 if the player is NOT on this type of object
CHECK_PLAYER_ON_ONE_TYPE_WATER_VEHICLE:
	push
	
	li $t0, 0			# The loop counter
	li $t1, waterObjectsOfType	# The loop maximum
	li $v0, 1
	CHECK_HIT_WATER_VEHICLE_LOOP:
		beq $t0, $t1, CHECK_HIT_WATER_VEHICLE_END
		
		sll $t3, $t0, wordSizeShiftAmt		# $t3 = loopCounter * 4
		add $t3, $t3, $a1			# $t3 = The ADDRESS OF the position of the loopCounter-th vehicle
		lw $t3, ($t3)				# $t3 = the position of the loopCounter-th vehicle
		
		subu $t4, $t3, $a0			# Calculate the distance from player to vehicle. If 0 or 1, die. Otherwise, next
		li $t2, waterVehicleWidth
		srl $t2, $t2, 1				# Set $t2 = roadVehicleWidth / 2
		sub $t2, $zero, $t2			# Set $t2 = -(roadVehicleWidth / 2)
		sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = -4 * roadVehicleWidth / 2
		
		beq $t4, $t2, ON_WATER_VEHICLE		# Check main (left) pixel
		beq $t4, 0, ON_WATER_VEHICLE		# Check second (right) pixel
		NOT_ON_WATER_VEHICLE:			# Not on log/turtle
			j ON_WATER_VEHICLE_END
		ON_WATER_VEHICLE:			# WAS on log/turtle
			li $v0, 0			# Return 0
			j CHECK_HIT_WATER_VEHICLE_END 	# break
		ON_WATER_VEHICLE_END:
		
		addiu $t0, $t0, 1			# Increment loop counter
		j CHECK_HIT_WATER_VEHICLE_LOOP
	CHECK_HIT_WATER_VEHICLE_END:
	
	return

# Checks whether a given player has hit a road vehicle
#	PARAMS:
#		$a0 stores the player's flag (0 = blue, 1 = pink)
CHECK_HIT_ROAD_VEHICLES:
	push
	allocate 1
		
	# Load addr(playerPosition)
	ternary_2args $a0, 0, lw, $t0, bluePlayerPosition, pinkPlayerPosition
	sw $t0, ($sp)
	
	la $a1, carPositionsArray		# Load positions array for cars
	lw $a2, ($sp)				# Load player position into $a2
	jal CHECK_HIT_ONE_TYPE_ROAD_VEHICLE	# Check if player has collided with a car
	
	# Reload the $t0 value
	lw $t0, ($sp)
	
	la $a1, truckPositionsArray		# Load positions array for trucks
	lw $a2, ($sp)				# Load player position into $a2
	jal CHECK_HIT_ONE_TYPE_ROAD_VEHICLE	# Check if player has collided with a truck
	
	free 1
	return

# A function to check whether or not the player hit a road vehicle of a certain type
#	PARAMS:
#		$a0 stores the flag of the type of player (0 = blue, 1 = pink)
#		$a1 stores the address of the first element in the road vehicle position array (e.g. carPositionsArray)
#		$a2 stores the players position
#	JUMPS:
#		Jumps to PLAYER_DIED if any collisions happen
CHECK_HIT_ONE_TYPE_ROAD_VEHICLE:
	push

	li $t0, 0					# The loop counter
	li $t1, roadObjectsOfType			# The loop maximum
	CHECK_HIT_ROAD_VEHICLE_LOOP:
		beq $t0, $t1, CHECK_HIT_ROAD_VEHICLE_END
		
		sll $t3, $t0, wordSizeShiftAmt		# $t3 = loopCounter * 4
		add $t3, $t3, $a1			# $t3 = The ADDRESS OF the position of the loopCounter-th vehicle
		lw $t3, ($t3)				# $t3 = the position of the loopCounter-th vehicle
		
		subu $t4, $t3, $a2			# Calculate the distance from player to vehicle. If 0 or 1, die. Otherwise, next
		li $t2, roadVehicleWidth
		srl $t2, $t2, 1				# Set $t2 = roadVehicleWidth / 2
		sub $t2, $zero, $t2			# Set $t2 = -(roadVehicleWidth / 2)
		sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = -4 * roadVehicleWidth / 2
		
		beq $t4, 0, KILL			# Check main (left) pixel
		beq $t4, $t2, KILL			# Check second (right) pixel
		DIDNT_KILL:
			j KILL_END
		KILL:
			jal PLAYER_DIED
			
			ternary_2args $a0, 0, la, $t0, CHECK_BLUE_COLLISIONS_DONE, CHECK_PINK_COLLISIONS_DONE
			return
			jr $t0
		KILL_END:
	
		addiu $t0, $t0, 1		# Increment loop counter
		j CHECK_HIT_ROAD_VEHICLE_LOOP
	CHECK_HIT_ROAD_VEHICLE_END:
	
	return

# A function that runs when a player dies
#	PARAMS:
#		$a0 stores the player's flag (0 = blue, 1 = pink)
PLAYER_DIED:
	push
	
	ternary_2args $a0, 0, la, $t0, bluePlayerPosition, pinkPlayerPosition
	ternary_2args $a0, 0, li, $t1, bluePlayerInitialPosition, pinkPlayerInitialPosition
	ternary_2args $a0, 0, la, $t2, bluePlayerLivesRemaining, pinkPlayerLivesRemaining
	ternary_2args $a0, 0, la, $t3, bluePlayerDirection, pinkPlayerDirection
	
	# Set direction
	sw $zero, ($t3)		# Set direction back to up
	
	# Set position
	sw $t1, ($t0)		# Set position to initial spot
	
	# Set lives remaining
	lw $t1, ($t2)		# Load livesRemaining
	subi $t1, $t1, 1	# Subtract 1 from livesRemaining
	sw $t1, ($t2)		# Resave the new value
	
	lw $t0, bluePlayerLivesRemaining
	lw $t1, pinkPlayerLivesRemaining
	add $t0, $t0, $t1
	beqz $t0, SET_GAME_STATE_TO_GAMEOVER_BOTH
	
	return

SET_GAME_STATE_TO_GAMEOVER_BOTH:
	push
	
	la $t0, gameState
	li $t1, 5
	sw $t1, ($t0)
	j main
	
	return

CHECK_AND_HANDLE_KEYPRESSES:
	push
	
	# Check for keypress
	lw $t8, 0xffff0000
	beq $t8, 0, HANDLE_KEYBOARD_INPUT_DONE
	HANDLE_KEYBOARD_INPUT:
		lw $t2, 0xffff0004
		
		lw $t0, bluePlayerLivesRemaining
		beqz $t0, SKIP_BLUE_PLAYER_KEYPRESSES 
		# Load blue data
		la $a0, bluePlayerDirection			# For changing the direction
		la $a1, bluePlayerMoving
		la $a2, bluePlayerPosition
		
		# Check blue keys
		beq $t2, 0x77, MOVE_UP				# if key = 'w'
		beq $t2, 0x61, MOVE_LEFT			# if key = 'a'
		beq $t2, 0x73, MOVE_DOWN			# if key = 's'
		beq $t2, 0x64, MOVE_RIGHT			# if key = 'd'
		
		SKIP_BLUE_PLAYER_KEYPRESSES:
		
		lw $t0, pinkPlayerLivesRemaining
		beqz $t0, SKIP_PINK_PLAYER_KEYPRESSES 
		# Load pink data
		la $a0, pinkPlayerDirection			# For changing the direction
		la $a1, pinkPlayerMoving
		la $a2, pinkPlayerPosition
		
		# Check pink keys
		beq $t2, 0x69, MOVE_UP				# if key = 'i'
		beq $t2, 0x6A, MOVE_LEFT			# if key = 'j'
		beq $t2, 0x6B, MOVE_DOWN			# if key = 'k'
		beq $t2, 0x6C, MOVE_RIGHT			# if key = 'l'
		
		SKIP_PINK_PLAYER_KEYPRESSES:
		
		j HANDLE_KEYBOARD_INPUT_DONE
	HANDLE_KEYBOARD_NO_INPUT:
		# Reset player moving back to 0
		la $t1, bluePlayerMoving
		la $t2, pinkPlayerMoving
		sw $zero, ($t1)
		sw $zero, ($t2)
	HANDLE_KEYBOARD_INPUT_DONE:
	
	return

# Move the player up a pixel
#	PARAMS:
#		$a0 stores the addr(playerDirection) for the given player (blue or pink)
#		$a1 stores the addr(playerMoving) for the given player (blue or pink)
#		$a2 stores the addr(playerPosition) for the given player (blue or pink)
#		$a3 stores the address of the label to exit to when movement is done
#	JUMPS:
#		Back into CHECK_AND_HANDLE_KEYPRESS
MOVE_UP:
	sw $zero, ($a0)			# Set playerDirection = 0

	lw $a0, movementAmountUp
	jal MOVE_PLAYER
	j HANDLE_KEYBOARD_INPUT_DONE

# Move the player down a pixel
#	PARAMS:
#		$a0 stores the addr(playerDirection) for the given player (blue or pink)
#		$a1 stores the addr(playerMoving) for the given player (blue or pink)
#		$a2 stores the addr(playerPosition) for the given player (blue or pink)
#		$a3 stores the address of the label to exit to when movement is done
#	JUMPS:
#		Back into CHECK_AND_HANDLE_KEYPRESS
MOVE_DOWN:
	li $t3, 2	
	sw $t3, ($a0)			# Set playerDirection = 2

	lw $a0, movementAmountDown
	jal MOVE_PLAYER
	j HANDLE_KEYBOARD_INPUT_DONE

# Move the player right a pixel
#	PARAMS:
#		$a0 stores the addr(playerDirection) for the given player (blue or pink)
#		$a1 stores the addr(playerMoving) for the given player (blue or pink)
#		$a2 stores the addr(playerPosition) for the given player (blue or pink)
#		$a3 stores the address of the label to exit to when movement is done
#	JUMPS:
#		Back into CHECK_AND_HANDLE_KEYPRESS
MOVE_RIGHT:
	li $t3, 1	
	sw $t3, ($a0)			# Set playerDirection = 1

	li $a0, tileTimesPixelConversion
	jal MOVE_PLAYER
	j HANDLE_KEYBOARD_INPUT_DONE

# Move the player left a tile
#	PARAMS:
#		$a0 stores the addr(playerDirection) for the given player (blue or pink)
#		$a1 stores the addr(playerMoving) for the given player (blue or pink)
#		$a2 stores the addr(playerPosition) for the given player (blue or pink)
#		$a3 stores the address of the label to exit to when movement is done
#	JUMPS:
#		Back into CHECK_AND_HANDLE_KEYPRESS
MOVE_LEFT:
	li $t3, 3	
	sw $t3, ($a0)			# Set playerDirection = 3

	li $a0, -tileTimesPixelConversion
	jal MOVE_PLAYER
	j HANDLE_KEYBOARD_INPUT_DONE
	
# Move the player by a pixel offset
#	PARAMS:
#		$a0 stores offset to move that player
#		$a1 stores the addr(playerMoving) for the given player (blue or pink)
#		$a2 stores the addr(playerPosition) for the given player (blue or pink)
#	JUMPS:
#		Back into CHECK_AND_HANDLE_KEYPRESS
MOVE_PLAYER:
	push
	
	lw $t0, ($a2)				# Load playerPosition
	li $t1, width
	
	ALLOW_PLAYER_MOVEMENT:
		li $t2, 1				# Set $t2 = 1
		sw $t2, ($a1) 				# Set player moving to 1
	
		add $t0, $t0, $a0			# Move a single tile in specified direction
		sw $t0, ($a2)				# Save that position back into the data
		j PLAYER_MOVEMENT_DECISION_END
	PLAYER_MOVEMENT_DECISION_END:
	
	
	return
