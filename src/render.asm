#################################
######			   ######
######      RENDERING      ######
######			   ######
#################################
.include "constants.asm"
.include "macros.asm"

.text
.globl RENDER
RENDER:
	push
	
	# Draw score region
	lw $a0, scoreRegionStart		
	li $a1, black				# Load the ending region color
	li $a2, scoreRegionHeight		# Load the ending region height
	jal DRAW_REGION
	
	# Draw the things in the score region
	jal DRAW_LIFE_HEARTS
	
	# Draw ending region
	lw $a0, endingRegionStart		# Load the first ending region pixel
	li $a1, endingColor			# Load the ending region color
	li $a2, endingRegionHeight		# Load the ending region height
	jal DRAW_REGION
	
	# Draw water region
	lw $a0, waterRegionStart		# Load the first water region pixel
	li $a1, waterColor			# Load the water region color
	li $a2, waterRegionHeight		# Load the water region height
	jal DRAW_REGION
	
	# Draw safe region
	lw $a0, safeRegionStart			# Load the first safe region pixel
	li $a1, safeColor			# Load the safe region color
	li $a2, safeRegionHeight		# Load the safe region height
	jal DRAW_REGION
	
	# Draw road region
	lw $a0,	roadRegionStart			# Load the first ending region pixel
	li $a1,	roadColor			# Load the ending region color
	li $a2, roadRegionHeight		# Load the ending region height
	jal DRAW_REGION
	
	# Draw starting region
	lw $a0, startingRegionStart		# Load the first ending region pixel
	li $a1, startingColor			# Load the ending region color
	li $a2, startingRegionHeight		# Load the ending region height
	jal DRAW_REGION
	
	# Draw all NPCs
	jal DRAW_NPCS
	
	# Draw the player
	la $a0, bluePlayerAnimationAddressArray
	lw $a1, bluePlayerPosition
	lw $a2, bluePlayerMoving
	li $a3, 0
	jal DRAW_ANIMATED_SPRITE
	
	# Draw the player
	la $a0, pinkPlayerAnimationAddressArray
	lw $a1, pinkPlayerPosition
	lw $a2, pinkPlayerMoving
	li $a3, 1
	jal DRAW_ANIMATED_SPRITE
	
	### RENDER THE BUFFER
	jal RENDER_BUFFER
	
	return


# A function to draw a single animated sprite.
#	NOTE
#		This function assumes the animation has 4 frames
#	PARAMS
#		$a0 is the address of the animation array of the object (e.g. playerAnimationAddressArray)
#		$a1 is the pixel location where to draw this animation (e.g. playerPosition)
#		$a2 is a flag to determine whether or not to animate. == 0 if DONT ANIMATE. Animate otherwise
#		$a3 is the player flag
DRAW_ANIMATED_SPRITE:
	push
	
	move $t1, $a0
	
	GET_ANIMATED_FRAME:
		lw $t0, animationCounter		# Get which frame needs to be shown
		sll $t0, $t0, wordSizeShiftAmt		# $t0 = (4 * animationCounter)
		
		# Get direction
		ternary_2args $a3, 0, lw, $t2, bluePlayerDirection, pinkPlayerDirection
		sll $t2, $t2, 2				# 4 directions
		sll $t2, $t2, wordSizeShiftAmt
		
		add $t0, $t0, $t2			# $t0 = (4 * animationCounter) + (4 * 4 * playerDirectionIndicator)
		
		add $t0, $t0, $t1			# $t0 = (4 * animationCounter) + (4 * 4 * playerDirectionIndicator) + arrayStart
		j LOAD_ANIMATION_FRAME
	DO_NOT_ANIMATE_FRAME:
		move $t0, $a0
		j LOAD_ANIMATION_FRAME
	LOAD_ANIMATION_FRAME:
		lw $t0, ($t0)				# Get the address of the array of colors that make up that frame
	
	move $a0, $a1					# Load the position
	move $a1, $t0					# Load the animation frame
	jal DRAW_8_BY_8_SPRITE				# Draw the frame
	
	return

DRAW_LIFE_HEARTS:
	push
	
	li $t0, 0
	lw $t1, pinkPlayerLivesRemaining		# Load the lives remaining
	DRAW_PINK_HEARTS_LOOP:
		beq $t0, $t1, DRAW_PINK_HEARTS_END
		
		li $t2, heartWidth
		mult $t2, $t0
		mflo $t2				# Set $t2 = heartWidth * loopCounter
		sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = 4 * heartWidth * loopCounter
		
		move $a0, $t2
		la $a1, pinkHeartColorArray
		jal DRAW_8_BY_8_SPRITE
		
		addiu $t0, $t0, 1
		j DRAW_PINK_HEARTS_LOOP
	DRAW_PINK_HEARTS_END:
	
	li $t0, 0
	lw $t1, bluePlayerLivesRemaining		# Load the lives remaining
	DRAW_BLUE_HEARTS_LOOP:
		beq $t0, $t1, DRAW_BLUE_HEARTS_END
		
		li $t2, heartWidth
		mult $t2, $t0
		mflo $t2				# Set $t2 = heartWidth * loopCounter
		
		li $t3, maxHearts			# Set $t3 = maxHearts
		sll $t3, $t3, heartWidthShiftAmt	# Set $t3 = heartWidth * maxHearts
		add $t2, $t2, $t3			# Set $t = (heartWidth * loopCounter) + (heartWidth * maxLives)
		sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = 4 * ((heartWidth * loopCounter) + (heartWidth * maxLives))
		
		move $a0, $t2
		la $a1, blueHeartColorArray
		jal DRAW_8_BY_8_SPRITE
		
		addiu $t0, $t0, 1
		j DRAW_BLUE_HEARTS_LOOP
	DRAW_BLUE_HEARTS_END:
	
	return

# A function to draw a single heart
#	PARAMS:
#		$a0 stores the first pixel at which to draw the heart
#		$a1 stores the array of pixels
DRAW_8_BY_8_SPRITE:
	push
	
	la $t9, frameBuffer
	#move $t9, $gp
	add $t9, $a0, $t9
	
	li $t8, width
	sll $t8, $t8, pixelConversionShiftAmt	# Set $t8 = width * pixelConversion
	
	move $t4, $a1
	# Row 1
	draw_offset 0 0
	draw_offset 4 4
	draw_offset 8 8
	draw_offset 12 12
	draw_offset 16 16
	draw_offset 20 20
	draw_offset 24 24
	draw_offset 28 28
	
	add $t9, $t9, $t8
	# Row 2
	draw_offset 32 0
	draw_offset 36 4
	draw_offset 40 8
	draw_offset 44 12
	draw_offset 48 16
	draw_offset 52 20
	draw_offset 56 24
	draw_offset 60 28 
	
	add $t9, $t9, $t8
	# Row 3
	draw_offset 64 0
	draw_offset 68 4
	draw_offset 72 8
	draw_offset 76 12
	draw_offset 80 16
	draw_offset 84 20
	draw_offset 88 24
	draw_offset 92 28
	
	add $t9, $t9, $t8
	# Row 4
	draw_offset 96 0
	draw_offset 100 4
	draw_offset 104 8
	draw_offset 108 12
	draw_offset 112 16
	draw_offset 116 20
	draw_offset 120 24
	draw_offset 124 28
	
	add $t9, $t9, $t8
	# Row 5
	draw_offset 128 0
	draw_offset 132 4
	draw_offset 136 8
	draw_offset 140 12
	draw_offset 144 16
	draw_offset 148	20
	draw_offset 152 24
	draw_offset 156 28
	
	add $t9, $t9, $t8
	# Row 6
	draw_offset 160 0
	draw_offset 164 4
	draw_offset 168 8
	draw_offset 172 12
	draw_offset 176 16
	draw_offset 180 20
	draw_offset 184 24
	draw_offset 188 28
	
	add $t9, $t9, $t8
	# Row 7
	draw_offset 192 0
	draw_offset 196 4
	draw_offset 200 8
	draw_offset 204 12
	draw_offset 208 16
	draw_offset 212 20
	draw_offset 216 24
	draw_offset 220 28
	
	add $t9, $t9, $t8
	# Row 8
	draw_offset 224 0
	draw_offset 228 4
	draw_offset 232 8
	draw_offset 236 12
	draw_offset 240 16
	draw_offset 244 20
	draw_offset 248 24
	draw_offset 252 28
	
	return

DRAW_NPCS:
	push
	
	# Render all cars
	la $a0, carImage
	la $a1, carPositionsArray
	li $a2, roadObjectsOfType
	jal DRAW_SINGLE_TYPE_OF_OBJECT
	
	# Render all trucks
	la $a0, truckImage
	la $a1, truckPositionsArray
	li $a2, roadObjectsOfType
	jal DRAW_SINGLE_TYPE_OF_OBJECT
	
	# Render all logs
	la $a0, logImage
	la $a1, logPositionsArray
	li $a2, waterObjectsOfType
	jal DRAW_SINGLE_TYPE_OF_OBJECT
	
	# Render all turtles
	la $a0, turtleImage
	la $a1, turtlePositionsArray
	li $a2, waterObjectsOfType
	jal DRAW_SINGLE_TYPE_OF_OBJECT
	
	return

# A function to draw a single type of object
#	PARAMS:
#		$a0 stores the address of the color array for that object
#		$a1 stores the address of the object's position array (e.g. carPositionsArray)
#		$a2 stores the number of objects of that type (e.g. roadObjectsOfType)
DRAW_SINGLE_TYPE_OF_OBJECT:
	# $t0 is the loop counter
	# $t1 is the loop maximum
	# $t2 is the address of the frame buffer
	# $t3 is the address of the pixel to draw
	push
	allocate 7
	
	li $t0, 0			# The loop counter
	move $t1, $a2			# The loop maximum
	DRAW_SINGLE_OBJECT_LOOP:
		beq $t0, $t1, DRAW_SINGLE_OBJECT_LOOP_END
		
		sll $t3, $t0, wordSizeShiftAmt	# $t3 = loopCounter * wordSize
		add $t3, $t3, $a1		# Get the address of the current object's position
		lw $t3, ($t3)			# Get the current object's position (beginning from 0)
		
		# Save the variables into the stack
		sw $t0, ($sp)
		sw $t1, 4($sp)
		sw $t2, 8($sp)
		sw $t3, 12($sp)
		sw $a0, 16($sp)
		sw $a1, 20($sp)
		sw $a2, 24($sp)
		
		move $a0, $a0			# Keep using the address of the color array
		move $a1, $t3			# Pass in the first pixel to draw at
		jal DRAW_OBJECT_SPRITE
		
		# Reload the variables we were using
		lw $t0, ($sp)
		lw $t1, 4($sp)
		lw $t2, 8($sp)
		lw $t3, 12($sp)
		lw $a0, 16($sp)
		lw $a1, 20($sp)
		lw $a2, 24($sp)
		
		addi $t0, $t0, 1
		j DRAW_SINGLE_OBJECT_LOOP
	DRAW_SINGLE_OBJECT_LOOP_END:
		li $t0, 0
	
	free 7
	return

# A function to draw the 16 pixels by 8 pixels sprite of an NPC
#	PARAMS:
#		$a0 is the array of colors
#		$a1 is the first pixel to render the object at
DRAW_OBJECT_SPRITE:
	# $t0 is the frame buffer address
	# $t1 is the loop counter for the Y coordinate
	# $t2 is the loop counter for the X coordinate
	# $t3 is the final pixel address to save in
	# $t4 is a calculation variable for $t3, then the address of the color to paint that pixel at $t3
	push
	
	la $t0, frameBuffer
	li $t1, 0						# Y loop counter
	DRAW_OBJECT_SPRITE_Y_LOOP:
		beq $t1, roadVehicleHeight, DRAW_OBJECT_SPRITE_Y_END
		
		li $t2, 0					# X loop counter
		DRAW_OBJECT_SPRITE_X_LOOP:
			beq $t2, roadVehicleWidth, DRAW_OBJECT_SPRITE_X_END	

			# Final pixel to draw is at address 4 * ((YCounter * width) + XCounter)	+ frameBuffer + startingPosition
			add $t3, $t0, $a1			# $t3 = frameBuffer + startingPosition
			li $t4, width
			mult $t4, $t1
			mflo $t4				# $t4 = YCounter * width
			add $t4, $t4, $t2			# $t4 = (YCounter * width) + XCounter
			sll $t4, $t4, pixelConversionShiftAmt	# $t4 = 4 * ((YCounter * width) + XCounter)
			add $t3, $t3, $t4			# $t3 = FINAL PIXEL POSITION = 4 * ((YCounter * width) + XCounter) + frameBuffer + startingPosition
			
			# Final address of the desired color to draw is at address 4 * (YCounter * roadVehicleWidth + XCounter)
			li $t4, roadVehicleWidth		# Set $t3 = roadVehicleWidth
			mult $t4, $t1
			mflo $t4				# Set $t3 = YCounter * roadVehicleWidth
			add $t4, $t4, $t2			# Set $t3 = YCounter * roadVehicleWidth + XCounter
			sll $t4, $t4, wordSizeShiftAmt		# Set $t3 = 4 * (YCounter * roadVehicleWidth + XCounter)
			add $t4, $t4, $a0			# Get the address of the color
			lw $t4, ($t4)				# Load the color
			
			# If the color is transparent, don't draw
			beq $t4, transparent, DO_NOT_DRAW_THIS_PIXEL
			# Paint that pixel the desired color
			sw $t4, ($t3)
			DO_NOT_DRAW_THIS_PIXEL:
			
			addiu $t2, $t2, 1
			j DRAW_OBJECT_SPRITE_X_LOOP
		DRAW_OBJECT_SPRITE_X_END:
		
		addiu $t1, $t1, 1
		j DRAW_OBJECT_SPRITE_Y_LOOP
	DRAW_OBJECT_SPRITE_Y_END:

	return

# A function to draw a single region dependent on the height and color of the region
# 	$a0 stores the index of the first pixel of the region
# 	$a1 stores the color of the region
#	$a2 stores the height of the desired region
DRAW_REGION:
	# $t1 stores the loop variable
	# $t2 stores the loop ending condition 4 * height * width
	# $t3 stores the address of the pixel to be painted
	push
	
	la $t0, frameBuffer
	add $t4, $t0, $a0			# Store the first pixel address
	li $t3, 0
	
	li $t2, width				# Load the width
	multu $t2, $a2
	mflo $t2				# Set $t2 = height * width
	sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = 4 * height * width
	
	li $t1, 0				# The loop counter
	DRAW_REGION_LOOP:
		beq $t1, $t2, DRAW_REGION_LOOP_END
		
		add $t3, $t4, $t1		# Offset first pixel address by loop counter
		sw $a1, ($t3)			# Paint that pixel the right color
		
		addiu $t1, $t1, pixelConversion
		j DRAW_REGION_LOOP
	DRAW_REGION_LOOP_END:
		move $t1, $zero
	
	return

# Copies the buffer contents into displayAddress
RENDER_BUFFER:
	# $t0 is the loop counter
	# $t1 is the frameBuffer address
	# $t4 is the address to copy INTO after $gp
	# $t5 is the address to copy FROM after frameBuffer
	push
	
	la $t1, frameBuffer
	
	li $t0, 0				# Loop counter
	RENDER_BUFFER_LOOP:
		beq $t0, bufferSize, RENDER_BUFFER_LOOP_END
		
		add $t4, $t0, $gp		# Get address to display
		add $t5, $t0, $t1		# Get address in frameBuffer
		lw $t5, ($t5)			# Get value in frameBuffer
		
		sw $t5, ($t4)			# Copy that value to displayBuffer
		
		addi $t0, $t0, pixelConversion
		j RENDER_BUFFER_LOOP
	RENDER_BUFFER_LOOP_END:
		li $t0, 0
	
	return
