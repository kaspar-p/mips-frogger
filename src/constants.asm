#################################
######			   ######
######      CONSTANTS      ######
######			   ######
#################################

.eqv black 0x000000
.eqv white 0xFFFFFF
.eqv transparent 0x00FFFFFF

.eqv wordSize 4
.eqv wordSizeShiftAmt 2		# = log2(wordSize)

.eqv height 128
.eqv heightShiftAmt 7		# = log2(height)
.eqv width 128
.eqv widthShiftAmt 7		# = log2(width)
.eqv bufferSize 0x10000		# width * height * pixelConversion

.eqv pixelConversion 4		# How many bytes per pixel
.eqv pixelConversionShiftAmt 2	# How many bits to shift to multiply by pixelConversionSize

.eqv tileSize 8
.eqv tileTimesPixelConversion 32# tileSize * pixelConversion
.eqv twoTiles 16

.eqv tileSizeShiftAmt 3
.eqv tilesPerRow 16		# width / tileSize
.eqv tilesPerColumn 16		# height / tileSize
.eqv tilesPerColumnShiftAmt 5	# log2(tilesPerColumn)

# Configure the height of the regions being used
#	ScoreRegionRatio = 3/32
#	EndingRegionRatio = 3/32
#	WaterRegionRatio = 1/4
#	SafeRegionRatio = 1/8
# 	RoadRegionRatio = 1/4
#	StartingRegionRation = 3/16

.eqv scoreRegionHeight 8
.eqv endingRegionHeight 16
.eqv waterRegionHeight 32
.eqv safeRegionHeight 16
.eqv roadRegionHeight 32
.eqv startingRegionHeight 24

# Configure colors for the world
.eqv safeRegionColor 0x9bd1a9
.eqv endingColor safeRegionColor	# Dark Green
.eqv waterColor 0x0000ff		# Blue
.eqv safeColor safeRegionColor		# Dark Green
.eqv roadColor 0x055550			# Black
.eqv startingColor safeRegionColor	# Dark Green

# Configure colors for objects
.eqv carColor 0x000000 		# Black
.eqv truckColor 0xFF0000	# Red
.eqv logColor 0x967B60		# Brown
.eqv turtleColor 0x60B388	# Cyan
.eqv pinkPlayerColor 0xDB2B69	# White
.eqv bluePlayerColor 0x6985d8	# White

#  Configure heart constants
.eqv heartWidth 8
.eqv heartWidthShiftAmt 3
.eqv heartHeight 8
.eqv heartHeightShiftAmt 3
.eqv maxHearts 5

.eqv pinkHeartLight 0xD75F89
.eqv pinkHeartMid 0xDB2B69
.eqv pinkHeartDark 0xB30945
.eqv pinkHeartSunSpot 0xFFD9E6

.eqv blueHeartLight 0x7b8fcc
.eqv blueHeartMid 0x6985d8
.eqv blueHeartDark 0x496bd3
.eqv blueHeartSunSpot 0xcad6fa

### NPC CONSTANTS
.eqv numberOfRows 2

.eqv roadObjectsPerRow 4
.eqv roadObjectsPerRowShiftAmt 2	# log2(roadObjectsPerRow)
.eqv spaceForRoadObjectsPerRow 16 	# waterObjectsPerRow * pixelConversion
.eqv roadObjectsOfType 8		# roadObjectsPerRow * numberOfRows
.eqv spaceForRoadObjectsOfType 32	# roadObjectsPerRow * numberOfRows * pixelConversion

.eqv waterObjectsPerRow 8
.eqv waterObjectsPerRowShiftAmt 3	# log2(waterObjectsPerRow)
.eqv spaceForWaterObjectsPerRow 32 	# waterObjectsPerRow * pixelConversion
.eqv waterObjectsOfType 16		# waterObjectsPerRow * numberOfRows
.eqv spaceForWaterObjectsOfType 64	# waterObjectsPerRow * numberOfRows * pixelConversion

# NPC sprite sizes
.eqv waterVehicleWidth 16		# 2 * (waterRegionHeight / numberOfRows)
.eqv waterVehicleHeight tileSize	# waterRegionHeight / numberOfRows
.eqv roadVehicleWidth 16		# 2 * (roadRegionHeight / numberOfRows)
.eqv roadVehicleHeight tileSize		# roadRegionHeight / numberOfRows

.eqv npcSpriteArraySpace 512		# roadVehicleHeight * roadVehicleWidth * pixelConversion
.eqv spriteArraySpace 256		# 8pixels * 8pixels * pixelConversion

# Velocity of objects in FRAMES per TILE
.eqv carVel 1
.eqv truckVel 4
.eqv logVel 1
.eqv turtleVel 4

.eqv velocityResetValue 1

# Whether or not they move forward or backward when they move
.eqv carDirection 1
.eqv truckDirection -1
.eqv logDirection 1
.eqv turtleDirection -1

# Configure player constants
.eqv pinkPlayerInitialPosition 28800 # 57600
.eqv bluePlayerInitialPosition 28832 # 57600
