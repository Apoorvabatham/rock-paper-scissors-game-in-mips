# vim:sw=2 syntax=asm
.data

	xx: .asciiz "X"
	dash: .asciiz "_"
	newline : .asciiz "\n"
	c0: .byte 0
	c1: .byte 0
	c2: .byte 0
	c3: .byte 0
	c4: .byte 0
	c5: .byte 0
	c6: .byte 0
	c7: .byte 0
	s0: .byte 0
	s1: .byte 0
	 
.text
  .globl simulate_automaton, print_tape, s0, s1, c0, c1, c2, c3, c4, c5, c6, c7

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	#rule_check
	lb $t9, 9($a0) #loading rule
	andi $t0, $t9, 1
	sb  $t0, c0
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb $t0, c1
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c2
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c3
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c4
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c5
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c6
		srl $t9, $t9, 1
	andi $t0, $t9, 1
	sb  $t0, c7
	
	#check_least:
	li $t3, 0
	lw $t8, 4($a0) #loading tape
	andi $t0, $t8, 1 #exat 1east
	sb $t0, s0
	lb $t0, 8($a0) #tape length
		ulta:
		andi  $t5, $t8, 1 #exat least sig 
		sll $t3, $t3,1 #shifting 
		or $t3, $t3, $t5 #getting rev val 
		srl  $t8, $t8, 1 #del least sig
		addi $t0, $t0, -1 #length as counter -1	
		bnez $t0, ulta #breaking check
	andi $t0, $t3, 1#exat most signi
	sb $t0, s1
	
	#loading		
	lw $t8, 4($a0) #loading tape
	lb $t7, 8($a0) #loading length
	li $t6, 0
	
	#least sig work
	andi $t0, $t8, 3
	lb $t1, s1
	beq $t0, 0, ase0
	beq $t0, 1, ase1
	beq $t0, 2, ase2
	beq $t0, 3, ase3
	
	ase0: beq $zero, $t1, cs1
	lb $t6, c1
	sll $t6, $t6, 1
	j work
	cs1:lb $t6, c0
	sll $t6, $t6, 1
	j work
	
	ase1: beq $zero, $t1, cs11
	lb $t6, c3
	sll $t6, $t6, 1
	j work
	cs11:lb $t6, c2
	sll $t6, $t6, 1
	j work 
	
	ase2: beq $zero, $t1, cs111
	lb $t6, c5
	sll $t6, $t6, 1
	j work
	cs111:lb $t6, c4
	sll $t6, $t6, 1
	j work
	
	ase3: beq $zero, $t1, cs1111
	lb $t6, c7
	sll $t6, $t6, 1
	j work
	cs1111:lb $t6, c6
	sll $t6, $t6, 1
	j work
	
	work :
	ble $t7 , 2, last #break when reach most
	andi $t0, $t8, 7 #exa 3 packet
	addi $t7, $t7, -1 #counter -1
	srl $t8, $t8, 1 #tape -1
	beq $t0, 0, zero	
	beq $t0, 1, one
	beq $t0, 2, two
	beq $t0, 3, three
	beq $t0, 4, four
	beq $t0, 5, five
	beq $t0, 6, six
	beq $t0, 7, seven
	
	zero : lb $t5, c0
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	one : lb $t5, c1
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	two : lb $t5, c2
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	three : lb $t5, c3
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	four : lb $t5, c4
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	five : lb $t5, c5
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	six : lb $t5, c6
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	seven : lb $t5, c7
	or $t6, $t6, $t5
	sll $t6, $t6, 1
	j work
	
	last :
	andi $t0, $t8, 3
	lb $t1, s0
	beq $t0, 0, case0
	beq $t0, 1, case1
	beq $t0, 2, case2
	beq $t0, 3, case3
	
	case0: beq $zero, $t1, cs0
	lb $t5, c4
	or $t6, $t6, $t5
	j ende
	cs0:lb $t5, c0
	or $t6, $t6, $t5
	j ende 
	
	case1: beq $zero, $t1, cs00
	lb $t5, c5
	or $t6, $t6, $t5
	j ende
	cs00:lb $t5, c1
	or $t6, $t6, $t5
	j ende 
	
	case2: beq $zero, $t1, cs000
	lb $t5, c6
	or $t6, $t6, $t5
	j ende
	cs000:lb $t5, c2
	or $t6, $t6, $t5
	j ende 
	
	case3: beq $zero, $t1, cs0000
	lb $t5, c7
	or $t6, $t6, $t5
	j ende
	cs0000:lb $t5, c3
	or $t6, $t6, $t5
	j ende 
	
		ende:li $t3, 0
		lb $t1, 8($a0)
		
		loo:	
	andi  $t5, $t6, 1 #exat least sig 
	sll $t3, $t3,1 #shifting 
	or $t3, $t3, $t5 #getting rev val 
	srl  $t6, $t6, 1 #del least sig
	addi $t1, $t1, -1 #length as counter -1	
	bnez $t1, loo #breaking check
	
	sw $t3, 4($a0)
		
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
  # TODO
  jr $ra

# Print the tape of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_
print_tape:
	addiu $sp, $sp, 4 #gen stack prt tape
	sw $ra, 0($sp) #st add pt
	move $a3, $a0
	li $t3, 0 #initializing t3
		
	lw $t0, 4($a0) #ext tape
	lb $t1, 8($a0) #ext length
	lb $t4, 8($a0) #ext length
	
	least:
	andi  $t5, $t0, 1 #exat least sig 
	sll $t3, $t3,1 #shifting 
	or $t3, $t3, $t5 #getting rev val 
	srl  $t0, $t0, 1 #del least sig
	addi $t1, $t1, -1 #length as counter -1	
	bnez $t1, least #breaking check
	
	next:
	addi $t4, $t4, -1 #length as counter -1
	andi $t2, $t3, 0x01 #exct least sig
	srl $t3, $t3, 1 #des least sig
	bltz  $t4, exit #counter <0
	
	beq $t2, 1, when_1 #to print
	beq $t2, 0, when_0 #to print
			
	when_1:
	li $v0, 4 
	la $a0, xx
	syscall
	li $t2, 0 #initializing 0
	j next
		
	when_0:
	li $v0, 4
	la $a0, dash
	syscall
	li $t2, 0 #initializing 0
	j next
	
	exit:
	li $v0, 4
	la $a0, newline
	syscall
	move $a0, $a3
	lw $ra, 0($sp) #ext add pt
	addiu $sp, $sp, 4 #des stack prt tape
  # TODO
  jr $ra