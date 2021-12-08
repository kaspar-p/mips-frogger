#########################################
######			           ######
######      BITMAP CONVERSION      ######
######			           ######
#########################################

.include "constants.asm"
.include "macros.asm"

.text
# A function to load a bitmap image into an array at a specified address
#	PARAMS:
#		$a0 stores the filename of the file to load
#		$a1 stores the address to load in
#		$a2 stores the size of the buffer to load
#		
#	RETURNS:
#		$v0 returns the width of the image IN BYTES
#		$v1 returns the height of the image IN BYTES
.globl LOAD_IMAGE_INTO_ARRAY
LOAD_IMAGE_INTO_ARRAY:
	push
	
	move $t0, $a0			# The filepath
	move $t1, $a1			# The address of the array to store
	move $t2, $a2
	
	li $v0, 13			# Set syscall OPEN FILE
	li $a1, 0			# Open for READ
	li $a2, 0			# IDK???
	syscall				# Open the file (file returned in $v0)
	move $s6, $v0
	
	blt $s6, 0, EXIT		# Error out if open incorrect
	
	li $v0, 14			# Set syscall READ FILE
	move $a0, $s6			# File descriptor
	move $a1, $t1			# The buffer to store in
	move $a2, $t2			# The size of the buffer
	syscall
	
	blt $v0, 0, EXIT		# Error out if read incorrect

	li $v0, 16			# Set syscall CLOSE FILE
	move $a0, $s6			# Set the file descriptor to close
	syscall
	
	blt $v0, 0, EXIT		# Error out of close incorrect

	
	return
