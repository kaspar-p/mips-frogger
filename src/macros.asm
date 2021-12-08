#################################
######			   ######
######        MACROS       ######
######			   ######
#################################

.macro push
	addiu $sp, $sp, -4	# Allocate a single word for storing $ra
	sw $ra, 0($sp)		# Save $ra into that word
.end_macro

.macro return
	lw $ra, 0($sp)		# Restore the $ra value
	addiu $sp, $sp, 4	# Free the stack pointer space
	
	jr $ra			# Return from the subroutine
.end_macro

# Allocate allocate_amount number of WORDS
.macro allocate (%allocate_amount)
	li $t6, %allocate_amount
	sll $t6, $t6, 2		# Calculate 4 * allocate_amount
	subu $sp, $sp, $t6	# $sp = $sp - 4 * allocate_amount
.end_macro

# Free free_amount number of WORDS
.macro free (%free_amount)
	li $t6, %free_amount
	sll $t6, $t6, 2		# Calculate 4 * free_amount
	addu $sp, $sp, $t6	# $sp = $sp + (4 * free_amount)
.end_macro

.macro draw_offset (%o1, %o2)
	addi $t5, $t4, %o1
	lw $t5, ($t5)
	
	
	beq $t5, transparent, SKIP_TRANSPARENT_PIXEL
	sw $t5, %o2($t9)
	SKIP_TRANSPARENT_PIXEL:	
.end_macro

# A macro to feign a ternary expression
# Think of as: IF %A == %B, THEN %WAS_TRUE_CLAUSE. OTHERWISE, %WAS_FALSE_CLAUSE
.macro ternary_2args (%A %B %LOAD_TYPE %REGISTER %TRUE_VALUE, %FALSE_VALUE)
	beq %A, %B, BRANCH_TERNARY_TRUE 
	BRANCH_TERNARY_FALSE:
		%LOAD_TYPE %REGISTER, %FALSE_VALUE
		j BRANCH_TERNARY_END
	BRANCH_TERNARY_TRUE:
		%LOAD_TYPE %REGISTER, %TRUE_VALUE
		j BRANCH_TERNARY_END
	BRANCH_TERNARY_END:
.end_macro

.macro ternary_3args (%A %B %LOAD_TYPE %REGISTER, %ARG1, %TRUE_VALUE, %FALSE_VALUE)
	beq %A, %B, BRANCH_TERNARY_TRUE 
	BRANCH_TERNARY_FALSE:
		%LOAD_TYPE %REGISTER, %ARG1, %FALSE_VALUE
		j BRANCH_TERNARY_END
	BRANCH_TERNARY_TRUE:
		%LOAD_TYPE %REGISTER, %ARG1, %TRUE_VALUE
		j BRANCH_TERNARY_END
	BRANCH_TERNARY_END:
.end_macro
