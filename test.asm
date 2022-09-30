.data

arr: .word '-','-','-', 1, 2, 3
Warn2: .asciiz"Value out of range :> \n"
Input1: .asciiz"Player1, Please choose your row and column. Values range from [1;5]: \n"
correct: .asciiz"Correct input"
.text
    # Player1's input		
    ReMove1_P1:	li $v0, 4
		la $a0, Input1
		syscall
		
		# Player1 's X_coord
		li $v0, 5
		syscall
		addi $a1, $v0, -1  # Adjust to fix with array index start from 0
		
		# Player1 's Y_coord
		li $v0, 5
		syscall
		addi $a2, $v0, -1  # Adjust to fix with array index start from 0
	
    # Check if values are out of range
    		addi $t0, $zero, 4
    		slt $t1, $t0, $a1
    		bne $t1, $zero, outRange1
    		
    		slt $t1, $a1, $zero
    		bne $t1, $zero, outRange1
    		
    		slt $t1, $t0, $a2
    		bne $t1, $zero, outRange1
    		
    		slt $t1, $a2, $zero
    		bne $t1, $zero, outRange1
    		j checkMid1
    		
    outRange1:	li $v0, 4
		la $a0, Warn2
		syscall
		j ReMove1_P1
		
    play1:	li $v0, 4
		la $a0, correct
		syscall 