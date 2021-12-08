.include "constants.asm"

.data	
	# Reserve space for $gp to not overflow into our variables. DO NOT REFERENCE, USE $gp FOR DRAWING
	screenBuffer: 	.align 2
			.space bufferSize
	# The buffer to write to, prevents flashing
	.globl frameBuffer
	frameBuffer: 	.align 2
			.space bufferSize
	
	# Configure game state - which part of the game they are on
	#	state = 0: starting screen
	#	state = 1: regular game
	#	state = 2: blue won, pink died
	#	state = 3: pink won, blue died
	#	state = 4: both won
	#	state = 5: both lost
	.globl gameState
	gameState: 				.word 0
	
	# Configure start, gameover, and win screens
	.globl startScreenImageFilename
	startScreenImageFilename: 		.asciiz "assets/kmp/screens/startScreen.kmp"
	.globl startScreenImage
	startScreenImage: 			.align 2
						.space bufferSize
	
	.globl winScreenImageFilename
	winScreenImageFilename: 		.asciiz "assets/kmp/screens/winScreen.kmp"
	.globl winScreenImage
	winScreenImage: 			.align 2
						.space bufferSize
	
	.globl gameOverBothScreenImageFilename
	gameOverBothScreenImageFilename: 	.asciiz "assets/kmp/screens/gameOverBoth.kmp"
	.globl gameOverBothScreenImage
	gameOverBothScreenImage: 		.align 2
						.space bufferSize
	
	.globl gameOverPinkScreenImageFilename
	gameOverPinkScreenImageFilename: 	.asciiz "assets/kmp/screens/gameOverPink.kmp"
	.globl gameOverPinkScreenImage
	gameOverPinkScreenImage: 		.align 2
						.space bufferSize
	
	.globl gameOverBlueScreenImageFilename
	gameOverBlueScreenImageFilename: 	.asciiz "assets/kmp/screens/gameOverBlue.kmp"
	.globl gameOverBlueScreenImage
	gameOverBlueScreenImage: 		.align 2
						.space bufferSize
	
	# Set the beginning pixels for each region - in memory addresses FROM displayAddress
	.globl scoreRegionStart
	scoreRegionStart: .word 0		# 0
	.globl endingRegionStart
	endingRegionStart: .word 0		# endingRegion = scoreRegionStart + 4 * scoreRegionHeight * width
	.globl waterRegionStart
	waterRegionStart: .word 0		# waterRegionStart = endingRegionStart + 4 * endingRegionHeight * width
	.globl safeRegionStart
	safeRegionStart: .word 0		# safeRegionStart = waterRegionStart + 4 * waterRegionHeight * width
	.globl roadRegionStart
	roadRegionStart: .word 0		# roadRegionStart = safeRegionStart + 4 * safeRegionHeight * width
	.globl startingRegionStart
	startingRegionStart: .word 0 		# startingRegionStart = roadRegionStart + 4 * roadRegionHeight * width
	
	# Configure the player positions
	.globl bluePlayerPosition
	bluePlayerPosition: 		.word 0
	.globl bluePlayerMoving
	bluePlayerMoving: 		.word 0
	.globl bluePlayerDirection
	bluePlayerDirection: 		.word 0
	.globl bluePlayerWon
	bluePlayerWon:			.word 0
	
	.globl pinkPlayerPosition
	pinkPlayerPosition: 		.word 0
	.globl pinkPlayerMoving
	pinkPlayerMoving: 		.word 0
	.globl pinkPlayerDirection
	pinkPlayerDirection: 		.word 0
	.globl pinkPlayerWon
	pinkPlayerWon:			.word 0
	
	# The counters to decide when to move
	# They begin at 1 so we can have a 1 -> 1 -> 1 every-frame movement
	# If they began at 0, The fastest an object could move would be every other frame
	.globl carVelCounter
 	carVelCounter: .byte velocityResetValue
 	.globl truckVelCounter
	truckVelCounter: .byte velocityResetValue
	.globl logVelCounter
	logVelCounter: .byte velocityResetValue
	.globl turtleVelCounter
	turtleVelCounter: .byte velocityResetValue
	
	# Configure the movement amounts vertically
	.globl movementAmountUp
	movementAmountUp: .word 0
	.globl movementAmountDown
	movementAmountDown: .word 0
	
	# The number of lives remaining
	.globl bluePlayerLivesRemaining
	bluePlayerLivesRemaining: .word maxHearts
	.globl pinkPlayerLivesRemaining
	pinkPlayerLivesRemaining: .word maxHearts
	
	# Animation counter
	.globl animationCounter
	animationCounter: .word 0
	
	# Animation arrays
	.globl bluePlayerAnimationAddressArray
	bluePlayerAnimationAddressArray: 	.align 2
						.space 64	# 16 words
	.globl pinkPlayerAnimationAddressArray
	pinkPlayerAnimationAddressArray: 	.align 2
						.space 64	# 16 words
	
	# Array for up to ten objects (cars/trucks/logs/turtles) per row
	.globl carPositionsArray
	carPositionsArray: 		.align 2 
					.space spaceForRoadObjectsOfType
	
	.globl truckPositionsArray
	truckPositionsArray: 		.align 2 
					.space spaceForRoadObjectsOfType
	
	.globl logPositionsArray
	logPositionsArray: 		.align 2 
					.space spaceForWaterObjectsOfType
	
	.globl turtlePositionsArray
	turtlePositionsArray: 		.align 2 
					.space spaceForWaterObjectsOfType
	
	.globl carImageFilename
	carImageFilename: 		.asciiz "assets/kmp/sprites/car.kmp"
	.globl carImage
	carImage: 			.align 2 
					.space npcSpriteArraySpace
	
	.globl truckImageFilename
	truckImageFilename: 		.asciiz "assets/kmp/sprites/truck.kmp"
	.globl truckImage
	truckImage: 			.align 2 
					.space npcSpriteArraySpace
	
	.globl logImageFilename
	logImageFilename: 		.asciiz "assets/kmp/sprites/log.kmp"
	.globl logImage
	logImage: 			.align 2 
					.space npcSpriteArraySpace
	
	.globl turtleImageFilename
	turtleImageFilename: 		.asciiz "assets/kmp/sprites/turtle.kmp"
	.globl turtleImage
	turtleImage: 			.align 2 
					.space npcSpriteArraySpace
	
	 .globl pinkPlayerImageUpFrame1Filename
	pinkPlayerImageUpFrame1Filename: 	.asciiz "assets/kmp/sprites/pink_frog_up_frame1.kmp"
	.globl pinkPlayerImageUpFrame1
	pinkPlayerImageUpFrame1: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageUpFrame2Filename
	pinkPlayerImageUpFrame2Filename: 	.asciiz "assets/kmp/sprites/pink_frog_up_frame2.kmp"
	.globl pinkPlayerImageUpFrame2
	pinkPlayerImageUpFrame2: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageUpFrame3Filename
	pinkPlayerImageUpFrame3Filename: 	.asciiz "assets/kmp/sprites/pink_frog_up_frame3.kmp"
	.globl pinkPlayerImageUpFrame3
	pinkPlayerImageUpFrame3: 		.align 2 
						.space spriteArraySpace
				
	.globl pinkPlayerImageRightFrame1Filename
	pinkPlayerImageRightFrame1Filename: 	.asciiz "assets/kmp/sprites/pink_frog_right_frame1.kmp"
	.globl pinkPlayerImageRightFrame1
	pinkPlayerImageRightFrame1: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageRightFrame2Filename
	pinkPlayerImageRightFrame2Filename: 	.asciiz "assets/kmp/sprites/pink_frog_right_frame2.kmp"
	.globl pinkPlayerImageRightFrame2
	pinkPlayerImageRightFrame2: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageRightFrame3Filename
	pinkPlayerImageRightFrame3Filename: 	.asciiz "assets/kmp/sprites/pink_frog_right_frame3.kmp"
	.globl pinkPlayerImageRightFrame3
	pinkPlayerImageRightFrame3: 		.align 2 
						.space spriteArraySpace
	
	.globl pinkPlayerImageDownFrame1Filename
	pinkPlayerImageDownFrame1Filename: 	.asciiz "assets/kmp/sprites/pink_frog_down_frame1.kmp"
	.globl pinkPlayerImageDownFrame1
	pinkPlayerImageDownFrame1: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageDownFrame2Filename
	pinkPlayerImageDownFrame2Filename: 	.asciiz "assets/kmp/sprites/pink_frog_down_frame2.kmp"
	.globl pinkPlayerImageDownFrame2
	pinkPlayerImageDownFrame2: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageDownFrame3Filename
	pinkPlayerImageDownFrame3Filename: 	.asciiz "assets/kmp/sprites/pink_frog_down_frame3.kmp"
	.globl pinkPlayerImageDownFrame3
	pinkPlayerImageDownFrame3: 		.align 2 
						.space spriteArraySpace
	
	.globl pinkPlayerImageLeftFrame1Filename
	pinkPlayerImageLeftFrame1Filename: 	.asciiz "assets/kmp/sprites/pink_frog_left_frame1.kmp"
	.globl pinkPlayerImageLeftFrame1
	pinkPlayerImageLeftFrame1: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageLeftFrame2Filename
	pinkPlayerImageLeftFrame2Filename: 	.asciiz "assets/kmp/sprites/pink_frog_left_frame2.kmp"
	.globl pinkPlayerImageLeftFrame2
	pinkPlayerImageLeftFrame2: 		.align 2 
						.space spriteArraySpace
	.globl pinkPlayerImageLeftFrame3Filename
	pinkPlayerImageLeftFrame3Filename: 	.asciiz "assets/kmp/sprites/pink_frog_left_frame3.kmp"
	.globl pinkPlayerImageLeftFrame3
	pinkPlayerImageLeftFrame3: 		.align 2 
						.space spriteArraySpace
	
    	.globl bluePlayerImageUpFrame1Filename
	bluePlayerImageUpFrame1Filename: 	.asciiz "assets/kmp/sprites/blue_frog_up_frame1.kmp"
	.globl bluePlayerImageUpFrame1
	bluePlayerImageUpFrame1: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageUpFrame2Filename
	bluePlayerImageUpFrame2Filename: 	.asciiz "assets/kmp/sprites/blue_frog_up_frame2.kmp"
	.globl bluePlayerImageUpFrame2
	bluePlayerImageUpFrame2: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageUpFrame3Filename
	bluePlayerImageUpFrame3Filename: 	.asciiz "assets/kmp/sprites/blue_frog_up_frame3.kmp"
	.globl bluePlayerImageUpFrame3
	bluePlayerImageUpFrame3: 		.align 2 
						.space spriteArraySpace
				
	.globl bluePlayerImageRightFrame1Filename
	bluePlayerImageRightFrame1Filename: 	.asciiz "assets/kmp/sprites/blue_frog_right_frame1.kmp"
	.globl bluePlayerImageRightFrame1
	bluePlayerImageRightFrame1: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageRightFrame2Filename
	bluePlayerImageRightFrame2Filename:	.asciiz "assets/kmp/sprites/blue_frog_right_frame2.kmp"
	.globl bluePlayerImageRightFrame2
	bluePlayerImageRightFrame2: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageRightFrame3Filename
	bluePlayerImageRightFrame3Filename: 	.asciiz "assets/kmp/sprites/blue_frog_right_frame3.kmp"
	.globl bluePlayerImageRightFrame3
	bluePlayerImageRightFrame3: 		.align 2 
						.space spriteArraySpace
	
	.globl bluePlayerImageDownFrame1Filename
	bluePlayerImageDownFrame1Filename: 	.asciiz "assets/kmp/sprites/blue_frog_down_frame1.kmp"
	.globl bluePlayerImageDownFrame1
	bluePlayerImageDownFrame1: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageDownFrame2Filename
	bluePlayerImageDownFrame2Filename: 	.asciiz "assets/kmp/sprites/blue_frog_down_frame2.kmp"
	.globl bluePlayerImageDownFrame2
	bluePlayerImageDownFrame2: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageDownFrame3Filename
	bluePlayerImageDownFrame3Filename: 	.asciiz "assets/kmp/sprites/blue_frog_down_frame3.kmp"
	.globl bluePlayerImageDownFrame3
	bluePlayerImageDownFrame3: 		.align 2 
						.space spriteArraySpace
	
	.globl bluePlayerImageLeftFrame1Filename
	bluePlayerImageLeftFrame1Filename: 	.asciiz "assets/kmp/sprites/blue_frog_left_frame1.kmp"
	.globl bluePlayerImageLeftFrame1
	bluePlayerImageLeftFrame1: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageLeftFrame2Filename
	bluePlayerImageLeftFrame2Filename: 	.asciiz "assets/kmp/sprites/blue_frog_left_frame2.kmp"
	.globl bluePlayerImageLeftFrame2
	bluePlayerImageLeftFrame2: 		.align 2 
						.space spriteArraySpace
	.globl bluePlayerImageLeftFrame3Filename
	bluePlayerImageLeftFrame3Filename: 	.asciiz "assets/kmp/sprites/blue_frog_left_frame3.kmp"
	.globl bluePlayerImageLeftFrame3
	bluePlayerImageLeftFrame3: 		.align 2 
						.space spriteArraySpace

	
	.globl pinkHeartColorArray
	pinkHeartColorArray: .word 	black,		black,		 black,			black,			black,			black,			black,		black,
					black,		black, 		 pinkHeartLight, 	black, 	   		black, 			pinkHeartDark, 		black, 		black,
					black,		pinkHeartLight,  pinkHeartLight, 	pinkHeartLight, 	pinkHeartMid, 		pinkHeartMid, 		pinkHeartDark, 	black,
					black,		pinkHeartLight,  pinkHeartSunSpot, 	pinkHeartMid, 		pinkHeartMid, 		pinkHeartMid, 		pinkHeartDark, 	black,
					black,		pinkHeartLight,  pinkHeartMid, 		pinkHeartMid, 		pinkHeartMid, 		pinkHeartDark, 		pinkHeartDark, 	black,
					black,		black, 		 pinkHeartMid, 		pinkHeartMid, 		pinkHeartDark, 		pinkHeartDark, 		black, 		black,
					black,		black, 		 black, 		pinkHeartDark,		pinkHeartDark, 		black, 			black,		black,
					black,		black,		 black,			black,			black,			black,			black,		black

	.globl blueHeartColorArray
	blueHeartColorArray: .word 	black,		black,		 black,			black,			black,			black,			black,		black,
					black,		black, 		 blueHeartLight, 	black, 	   		black, 			blueHeartDark, 		black, 		black,
					black,		blueHeartLight,	 blueHeartLight, 	blueHeartLight, 	blueHeartMid, 		blueHeartMid, 		blueHeartDark, 	black,
					black,		blueHeartLight,  blueHeartSunSpot, 	blueHeartMid, 		blueHeartMid, 		blueHeartMid, 		blueHeartDark, 	black,
					black,		blueHeartLight,  blueHeartMid, 		blueHeartMid, 		blueHeartMid, 		blueHeartDark, 		blueHeartDark, 	black,
					black,		black, 		 blueHeartMid, 		blueHeartMid, 		blueHeartDark, 		blueHeartDark, 		black, 		black,
					black,		black, 		 black, 		blueHeartDark,		blueHeartDark, 		black, 			black,		black,
					black,		black,		 black,			black,			black,			black,			black,		black

