# vim:sw=2 syntax=asm
.data
	w: .asciiz "W"
	l: .asciiz "L"
	t: .asciiz "T"
	

.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout
play_game_once:

	addiu $sp, $sp, -8 #gen stack pgo
	sw $ra, 0($sp) #add pgo
	
 	jal gen_byte #P1 move
 	sw $v0, 4($sp) #store p1 move
  
 	jal gen_byte #P2 move
 	move $t2, $v0 #p2 move
 	
 	lw $t1, 4($sp) #p1 move
 	
 	beq $t1, $t2, tie #check tie
 	beq $t1, 0, check_r #P1 rock
 	beq $t1, 1, check_p #P1 paper
 	beq $t1, 2, check_s #P1 scissors
 	
 	check_p:
 	beq $t2, 0, win #paper Vs rock
 	beq $t2, 2, lose #paper Vs scissor
 	
 	check_r:
 	beq $t2, 1, lose #rock VS paper
 	beq $t2, 2, win #rock VS scissors 
 	
 	check_s:
 	beq $t2, 1, win #scissor VS paper
 	beq $t2, 0, lose #scissor VS rock
 	 	 
 	win:
 	la $t3, w #win t3=W
 	j end 
 	 
 	lose:
 	la $t3, l #lose 
 	j end
 	
 	tie:
 	la $t3, t #tie
 	j end
 	
 	end:
 	lw $ra, 0($sp) #add pgo
 	addiu $sp, $sp, 8 #dest stack pgo
 	li $v0, 4 #print
 	la $a0, ($t3) #print result letter
 	syscall 
  # TODO
  jr $ra
