# vim:sw=2 syntax=asm
.data
 blah : .byte 0
 blah2 : .byte 0
.text
  .globl gen_byte, gen_bit, blah, blah2

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#
gen_byte:
	addiu $sp $sp -4 #stack for gbyte
	sw $ra, 0($sp) #store add gbyte
	  jal gen_bit #bit1
	  	lb $t0, blah2
	sll $t0, $v0, 1 #set bit1
	sb $t0, blah2
	jal gen_bit #bit2
	lb $t0, blah2
	or  $t0, $v0, $t0 #set bit2
	
	bgeu $t0, 3, gen_byte #check gbyte
	move $v0 $t0 #gbyte output
	lw $ra, 0($sp) #addres  gbyte
	addiu $sp $sp 4 #d stack for gbyte
	
	
  # TODO
  jr $ra

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#
gen_bit: 
  # TODO
  move $t0, $zero
  lw $t0, 0($a0)
  beqz $t0, zero

  
  lb $t1, 10($a0)
  sb $t1, blah
lpp:
  lb $t1, blah
   beqz  $t1, tata
  addiu $sp, $sp, -4
  sw $ra, 0($sp)
   addiu $t1, $t1, -1
   sb $t1, blah
   jal simulate_automaton
   lw $ra, 0($sp)
   addiu $sp, $sp, 4
   j lpp
    tata:
    lb $t1, 11($a0)
    lw $t2, 4($a0)
    lb $t0, 8($a0)
    li $t5, 0
    li $t3, 0
    ult:
		andi  $t5, $t2, 1 #exat least sig 
		sll $t3, $t3,1 #shifting 
		or $t3, $t3, $t5 #getting rev val 
		srl  $t2, $t2, 1 #del least sig
		addi $t0, $t0, -1 #length as counter -1	
		bnez $t0, ult #breaking check
    
    extract:
    beqz $t1, samapt
    addiu $t1, $t1, -1
    srl $t3, $t3, 1
    j extract
    samapt:
  andi $v0, $t3, 1
  j khtm
  zero:
  move $a1, $a0
  li $v0, 41 #generate random
  li $a0, 0 #something
  syscall
  andi $v0, $a0, 1 #bit extraction 
  move $a0, $a1
    
  khtm:
  jr $ra
