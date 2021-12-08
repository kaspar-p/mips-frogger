# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 1
# - Unit height in pixels: 1
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.include "constants.asm"
.include "macros.asm"

.text
.globl main
main:
.globl RESET
RESET:
.globl START
START:	
	la $t0, bluePlayerLivesRemaining
	la $t1, pinkPlayerLivesRemaining
	li $t2, maxHearts
	sw $t2, ($t0)
	sw $t2, ($t1)
	
	la $t0, bluePlayerWon
	la $t1, pinkPlayerWon
	sw $zero, ($t0)
	sw $zero, ($t0)
	
	# Initialize sprites
	jal INITIALIZE_SPRITES
	
	# Initialize the animation arrays for ease of animation
	jal INITIALIZE_ANIMATION_ARRAYS
	
	# Initialize the screens like starting screen, gameover screen, and win screen
	jal INITIALIZE_SCREENS
	
	# Initialize playerPosition for blue and pink
	la $t0, bluePlayerPosition
	li $t1, bluePlayerInitialPosition
	sw $t1, ($t0)
	
	la $t0, pinkPlayerPosition
	li $t1, pinkPlayerInitialPosition
	sw $t1, ($t0)
	
	### INITIALIZE STARTING REGION NUMBERS
	
	# Initialize scoreRegionStart
	la $t0, scoreRegionStart
	sw $zero, ($t0)				# Initialize scoreRegionStart to 0
	
	# Initialize endingRegionStart
	la $a0, endingRegionStart
	lw $a1, scoreRegionStart
	li $a2, scoreRegionHeight
	jal INITIALIZE_NEXT_REGION
	
	# Initialize waterRegionStart
	la $a0, waterRegionStart
	lw $a1, endingRegionStart
	li $a2, endingRegionHeight
	jal INITIALIZE_NEXT_REGION
	
	# Initialize safeRegionStart
	la $a0, safeRegionStart
	lw $a1, waterRegionStart
	li $a2, waterRegionHeight
	jal INITIALIZE_NEXT_REGION
	
	# Initialize roadRegionStart
	la $a0, roadRegionStart
	lw $a1, safeRegionStart
	li $a2, safeRegionHeight
	jal INITIALIZE_NEXT_REGION
	
	# Initialize startingRegionStart
	la $a0, startingRegionStart
	lw $a1, roadRegionStart
	li $a2, roadRegionHeight
	jal INITIALIZE_NEXT_REGION
	
	# Initialize positions of NPCs
	la $a0, carPositionsArray		# Load cars array
	li $a1, 1				# Position on odd rows
	lw $a2, roadRegionStart			# Load road starting address
	li $a3, roadObjectsPerRow
	jal INITIALIZE_OBJECT_TYPE_POSITIONS	# Initialize car positions
	
	la $a0, truckPositionsArray		# Load trucks array
	li $a1, 0				# Position on even rows
	lw $a2, roadRegionStart			# Load road starting address
	li $a3, roadObjectsPerRow
	jal INITIALIZE_OBJECT_TYPE_POSITIONS	# Initialize truck positions
	
	la $a0, logPositionsArray		# Load logs array
	li $a1, 1				# Position on odd rows
	lw $a2, waterRegionStart		# Load water starting address
	li $a3, waterObjectsPerRow
	jal INITIALIZE_OBJECT_TYPE_POSITIONS	# Initialize log positions
	
	la $a0, turtlePositionsArray		# Load turtles array
	li $a1, 0				# Position on even rows
	lw $a2, waterRegionStart		# Load water starting address
	li $a3, waterObjectsPerRow
	jal INITIALIZE_OBJECT_TYPE_POSITIONS	# Initialize turtle positions
	
	# Initialize the movement up and down values
	li $t1, width
	li $t2, pixelConversion
	mult $t1, $t2				# Set $t2 = width * pixelConversion
	mflo $t1
	sll $t1, $t1, tileSizeShiftAmt		# Set $t2 = width * pixelConversion * tileSize
	la $t0, movementAmountDown		# Load movementAmountDown
	sw $t1, ($t0)				# Save movementAmountDown = width * pixelConversion
	la $t0, movementAmountUp		# Load movementAmountUp
	sub $t1, $zero, $t1			# Set $t1 = -(movementAmountDown)
	sw $t1 ($t0)				# Save movementAmountUp = -(movementAmountDown)
	
	j GAME_LOOP

INITIALIZE_SCREENS:
	push
	
	la $a0, startScreenImageFilename
	la $a1, startScreenImage
	li $a2, bufferSize
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, winScreenImageFilename
	la $a1, winScreenImage
	li $a2, bufferSize
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, gameOverBothScreenImageFilename
	la $a1, gameOverBothScreenImage
	li $a2, bufferSize
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, gameOverBlueScreenImageFilename
	la $a1, gameOverBlueScreenImage
	li $a2, bufferSize
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, gameOverPinkScreenImageFilename
	la $a1, gameOverPinkScreenImage
	li $a2, bufferSize
	jal LOAD_IMAGE_INTO_ARRAY
	
	return

INITIALIZE_ANIMATION_ARRAYS:
	push
	
	### BLUE PLAYER ANIMATIONS
	
	la $t0, bluePlayerAnimationAddressArray
	
	# Up
	la $t1, bluePlayerImageUpFrame1
	la $t2, bluePlayerImageUpFrame2
	la $t3, bluePlayerImageUpFrame3
	la $t4, bluePlayerImageUpFrame2		# Get the frame arrays
	
	sw $t1, 0($t0)				# Store each address
	sw $t2, 4($t0)
	sw $t3, 8($t0)
	sw $t4, 12($t0)
	
	# Right
	la $t1, bluePlayerImageRightFrame1
	la $t2, bluePlayerImageRightFrame2
	la $t3, bluePlayerImageRightFrame3
	la $t4, bluePlayerImageRightFrame2	# Get the frame arrays
	
	sw $t1, 16($t0)				# Store each address
	sw $t2, 20($t0)
	sw $t3, 24($t0)
	sw $t4, 28($t0)
	
	# Down
	la $t1, bluePlayerImageDownFrame1
	la $t2, bluePlayerImageDownFrame2
	la $t3, bluePlayerImageDownFrame3
	la $t4, bluePlayerImageDownFrame2	# Get the frame arrays
	
	sw $t1, 32($t0)				# Store each address
	sw $t2, 36($t0)
	sw $t3, 40($t0)
	sw $t4, 44($t0)
	
	# Left
	la $t1, bluePlayerImageLeftFrame1
	la $t2, bluePlayerImageLeftFrame2
	la $t3, bluePlayerImageLeftFrame3
	la $t4, bluePlayerImageLeftFrame2	# Get the frame arrays
	
	sw $t1, 48($t0)				# Store each address
	sw $t2, 52($t0)
	sw $t3, 56($t0)
	sw $t4, 60($t0)
	
	### PINK PLAYER ANIMATIONS
	
	la $t0, pinkPlayerAnimationAddressArray
	
	# Up
	la $t1, pinkPlayerImageUpFrame1
	la $t2, pinkPlayerImageUpFrame2
	la $t3, pinkPlayerImageUpFrame3
	la $t4, pinkPlayerImageUpFrame2		# Get the frame arrays
	
	sw $t1, 0($t0)				# Store each address
	sw $t2, 4($t0)
	sw $t3, 8($t0)
	sw $t4, 12($t0)
	
	# Right
	la $t1, pinkPlayerImageRightFrame1
	la $t2, pinkPlayerImageRightFrame2
	la $t3, pinkPlayerImageRightFrame3
	la $t4, pinkPlayerImageRightFrame2	# Get the frame arrays
	
	sw $t1, 16($t0)				# Store each address
	sw $t2, 20($t0)
	sw $t3, 24($t0)
	sw $t4, 28($t0)
	
	# Down
	la $t1, pinkPlayerImageDownFrame1
	la $t2, pinkPlayerImageDownFrame2
	la $t3, pinkPlayerImageDownFrame3
	la $t4, pinkPlayerImageDownFrame2	# Get the frame arrays
	
	sw $t1, 32($t0)				# Store each address
	sw $t2, 36($t0)
	sw $t3, 40($t0)
	sw $t4, 44($t0)
	
	# Left
	la $t1, pinkPlayerImageLeftFrame1
	la $t2, pinkPlayerImageLeftFrame2
	la $t3, pinkPlayerImageLeftFrame3
	la $t4, pinkPlayerImageLeftFrame2	# Get the frame arrays
	
	sw $t1, 48($t0)				# Store each address
	sw $t2, 52($t0)
	sw $t3, 56($t0)
	sw $t4, 60($t0)

	return

INITIALIZE_SPRITES:
	push
	
	# Initialize car
	la $a0, carImageFilename
	la $a1, carImage
	li $a2, npcSpriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Initialize truck
	la $a0, truckImageFilename
	la $a1, truckImage
	li $a2, npcSpriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Initialize log
	la $a0, logImageFilename
	la $a1, logImage
	li $a2, npcSpriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Initialize turtle
	la $a0, turtleImageFilename
	la $a1, turtleImage
	li $a2, npcSpriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Initialize BLUE FROG
	
	# Up
	la $a0, bluePlayerImageUpFrame1Filename
	la $a1, bluePlayerImageUpFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageUpFrame2Filename
	la $a1, bluePlayerImageUpFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageUpFrame3Filename
	la $a1, bluePlayerImageUpFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Right
	la $a0, bluePlayerImageRightFrame1Filename
	la $a1, bluePlayerImageRightFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageRightFrame2Filename
	la $a1, bluePlayerImageRightFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageRightFrame3Filename
	la $a1, bluePlayerImageRightFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Down
	la $a0, bluePlayerImageDownFrame1Filename
	la $a1, bluePlayerImageDownFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageDownFrame2Filename
	la $a1, bluePlayerImageDownFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageDownFrame3Filename
	la $a1, bluePlayerImageDownFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Left
	la $a0, bluePlayerImageLeftFrame1Filename
	la $a1, bluePlayerImageLeftFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageLeftFrame2Filename
	la $a1, bluePlayerImageLeftFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, bluePlayerImageLeftFrame3Filename
	la $a1, bluePlayerImageLeftFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY

	# Initialize PINK FROG
	
	# Up
	la $a0, pinkPlayerImageUpFrame1Filename
	la $a1, pinkPlayerImageUpFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageUpFrame2Filename
	la $a1, pinkPlayerImageUpFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageUpFrame3Filename
	la $a1, pinkPlayerImageUpFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Right
	la $a0, pinkPlayerImageRightFrame1Filename
	la $a1, pinkPlayerImageRightFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageRightFrame2Filename
	la $a1, pinkPlayerImageRightFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageRightFrame3Filename
	la $a1, pinkPlayerImageRightFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Down
	la $a0, pinkPlayerImageDownFrame1Filename
	la $a1, pinkPlayerImageDownFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageDownFrame2Filename
	la $a1, pinkPlayerImageDownFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageDownFrame3Filename
	la $a1, pinkPlayerImageDownFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	# Left
	la $a0, pinkPlayerImageLeftFrame1Filename
	la $a1, pinkPlayerImageLeftFrame1
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageLeftFrame2Filename
	la $a1, pinkPlayerImageLeftFrame2
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY
	
	la $a0, pinkPlayerImageLeftFrame3Filename
	la $a1, pinkPlayerImageLeftFrame3
	li $a2, spriteArraySpace
	jal LOAD_IMAGE_INTO_ARRAY

	
	return

# A function to initialize the starting position of the next region
#	PARAMS:
#		$a0 stores the address to save the region start
#		$a1 stores the start of the region preceding
#		$a2 stores the height of the region preceding
#	RETURNS:
#		$v0 stores the start of the region we initialized
INITIALIZE_NEXT_REGION:
	push

	sll $t2, $a2, widthShiftAmt		# Set $t2 = width * precedingRegionHeight
	sll $t2, $t2, pixelConversionShiftAmt	# Set $t2 = 4 * width * precedingRegionHeight
	add $t2, $t2, $a1			# Set $t2 = scoreRegionStart + 4 * width * scoreRegionHeight
	sw $t2, ($a0)				# Save the new start
	
	return

# A function to initialize the positions (randomly) for a type of object
#	$a0 stores the address of the first element of the array of the object positions
#	$a1 stores a 0 if we are to draw only on EVEN rows, and a 1 if we are to draw only on ODD rows
#	$a2 stores the location the first pixel of the section the objects are in
#	$a3 stores the number of objects per row of this type
INITIALIZE_OBJECT_TYPE_POSITIONS:
	# $t0 stores the outer loop counter
	# $t1 stores the outer loop maximum
	# $t2 stores the final pixel position
	# $t3 stores the address of the position to be saved
	# $t4 stores the inner loop counter
	# $t5 stores the inner loop maximum
	# $t6 stores the random horizontal position
	# $t7 stores the row number offset based on outer loop counter
	# $t8 stores a copy of $a0
	# $t9 stores a copy of $a1
	push
	
	move $t8, $a0						# Copy since we will overwrite the $a0 value
	move $t9, $a1						# Copy since we will overwrite the $a1 value
	
	li $t0, 0						# Loop counter
	li $t1, numberOfRows					# Max loop counter = numberOfRows
	INITIALIZE_OBJECT_ROWS_LOOP:
		beq $t0, $t1, INITIALIZE_OBJECT_ROWS_END
		
		li $t4, 0					# Inner loop counter
		move $t5, $a3					# Number of objects per row (8 or 16, depending on the type of the object)
		INITIALIZE_OBJECTS_IN_ROW_LOOP:
			beq $t4, $t5, INITIALIZE_OBJECTS_IN_ROW_END
			
			# Final pixel position = startPosition + (2 * outerLoopCounter * width * pixelConversion * rowHeight) + randomHorizontalPosition
			
			# Calculate position of the pixel
			li $t6, tilesPerRow				# $t6 = tilesPerRow
			addiu $t6, $t6, -1				# $t6 = tilesPerRow - 1
			li $v0, 42					# Mark the syscall to be a PRNG operation
			li $a0, 0					# ID = 0 for PRN generator
			move $a1, $t6					# Set upperbound for number to be tilesPerRow - 1
			syscall						# Generate the random number, stored in $a0
			sll $t6, $a0, pixelConversionShiftAmt		# Store $t6 = randomHorizontalPosition (in divisible by 4 pixel space)
			sll $t6, $t6, tileSizeShiftAmt			# Store $t6 = randomHorizontalPosition AS A TILE POSITION (divisible by tilesPerRow)
			
			sll $t7, $t0, widthShiftAmt			# Store $t7 = outerLoopCounter * width
			sll $t7, $t7, 1					# Store $t7 = 2 * outerLoopCounter * width
			sll $t7, $t7, tileSizeShiftAmt			# Stpre $t7 = 2 * outerLoopCounter * width * tileSize
			sll $t7, $t7, pixelConversionShiftAmt		# Store $t7 = 2 * outerLoopCounter * width * pixelConversion * tileSize
			
			move $t2, $a2					# $t2 = startPosition
			add $t2, $t2, $t7				# $t2 = startPosition + (2 * outerLoopCounter * width * pixelConversion * tileSize)
			add $t2, $t2, $t6				# $t2 = startPosition + (2 * outerLoopCounter * width * pixelConversion * tileSize) + randomHorizontalPosition
			
			sll $t7, $t9, widthShiftAmt			# If $a1 = 1, then $t7 = width. If $a1 = 0, then $t7 = 0
			sll $t7, $t7, pixelConversionShiftAmt		# If $a1 = 1, then $t7 = 4 * width. If $a1 = 0, then $t7 = 0
			sll $t7, $t7, tileSizeShiftAmt			# If $a1 = 1, then $t7 = 4 * width * tileSize. If $a1 = 0, then $t7 = 0	
					
			add $t2, $t2, $t7				# Offset by even/odd row
			
			# Calculate address to save that position in
			mult $t0, $t5
			mflo $t3					# $t3 = outerLoopCounter * objectsInRow
			add $t3, $t3, $t4				# $t3 = outerLoopCounter * objectsInRow + innerLoopCounter
			sll $t3, $t3, wordSizeShiftAmt			# $t3 = 4 * (outerLoopCounter * objectsInRow + innerLoopCounter)
			add $t3, $t3, $t8				# Offset by address
			sw $t2, ($t3)					# Store the byte of the position
		
			addiu $t4, $t4, 1				# Increment the inner loop counter
			j INITIALIZE_OBJECTS_IN_ROW_LOOP
		INITIALIZE_OBJECTS_IN_ROW_END:
			li $t4, 0					# Reset the inner loop counter
		
		addiu $t0, $t0, 1				# Increment loop counter
		j INITIALIZE_OBJECT_ROWS_LOOP
	INITIALIZE_OBJECT_ROWS_END:
	
	return


GAME_LOOP:
	push

	jal UPDATE
	jal RENDER
	
	# Sleep for 33ms for about 30fps
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 33	# 33 ms
	syscall
	
	# Update the animation counter mod 4
	la $t0, animationCounter
	lw $t1, ($t0)
	add $t1, $t1, 1
	beq $t1, 4, RESET_ANIMATION_COUNTER
	j SAVE_ANIMATION_COUNTER
	RESET_ANIMATION_COUNTER:
		li $t1, 0			# Set to 0
	SAVE_ANIMATION_COUNTER:
	sw $t1, ($t0)				# Resave the animation counter
	
	j GAME_LOOP

	return

.globl EXIT
EXIT:
	li $v0, 10 		# terminate the program gracefully
	syscall
