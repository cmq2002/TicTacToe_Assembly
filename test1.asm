.data
# Initialize data for the board
board: .word R1, R2, R3, R4, R5
R1: .word '-', '-', '-', '-', '-'
R2: .word '-', '-', '-', '-', '-'
R3: .word '-', '-', '-', '-', '-'
R4: .word '-', '-', '-', '-', '-'
R5: .word '-', '-', '-', '-', '-'
# For undo option
back_up: .word R6, R7, R8, R9, R10  
R6: .word '-', '-', '-', '-', '-'
R7: .word '-', '-', '-', '-', '-'
R8: .word '-', '-', '-', '-', '-'
R9: .word '-', '-', '-', '-', '-'
R10: .word '-', '-', '-', '-', '-'

size: .word 5
# Information
greeting: .asciiz "\nWelcome to the Tic-Tac-Toe game! Here are the rules for the game:\n \n"
greeting1: .asciiz "\n Would you like to start the game now? (1=Yes/0=No)->Choose:"
noplay: .asciiz"\n---------------------------------------------------TOO SAD :<------------------------------------------------------------\n"
inst1: 	.asciiz"1. Input:Players need to type in the row and column for a desire location on the board\n\n"
inst1.1:.asciiz"         The index stars from 1. Ex: top left location has the coordinate of (1,1)\n\n"
inst1.2:.asciiz"         At the first move, both players are not allowed to choose the central point (row:3. column;3)\n\n"
inst1.3:.asciiz"         If the location has been choosen or values are out of range, players will be asked to enter again\n\n"
inst2:  .asciiz"2. Winning Condition: Any player who has 3 points on a row, column or diagonal will be a winner\n\n"     
inst3:  .asciiz"3. Additional option: Players can undo 1 move before the opponent plays\n"
# Output
separate:.asciiz"\n-----------------------------------------LET'S HAVE FUN :D-------------------------------------------------------"
newline: .asciiz "\n                                        --- --- --- --- ---\n"
spaceRow: .asciiz "                                       | "
space: .asciiz " | "
Input1: .asciiz"Player1, Please choose your row and column. Values range from [1;5]: \n"
Input2: .asciiz"Player2, Please choose your row and column. Values range from [1;5]: \n"
Warn1: .asciiz"!!! Warning: Your first move was at the central point! Please choose again :> \n"
Warn2: .asciiz"!!! Warning: Value out of range :> \n"
Warn3: .asciiz"!!! Warning: Location has been occupied. Please choose again :> \n"
Undo: .asciiz"Do you want to Undo?(1=Yes/0=No)"  
Newgame: .asciiz "                           Would you like to start a new game? (1=Yes/0=No)->Choose:"
P1_Win: .asciiz"\n--------------------------------  The Winner is Player1. Congratulation! ;v  -------------------------------------------\n"
P2_Win: .asciiz"\n--------------------------------  The Winner is Player2. Congratulation! ;v  -------------------------------------------\n"
Drawn: .asciiz"\n  No winner. A drawn game  =(( \n"

.text
main: 
     # Print greeting and instruction		
     starting:	li $v0, 4
		la $a0, greeting
		syscall
				
		li $v0, 4
		la $a0, inst1
		syscall
				
		li $v0, 4
		la $a0, inst1.1
		syscall
				
		li $v0, 4
		la $a0, inst1.2
		syscall
				
		li $v0, 4
		la $a0, inst1.3
		syscall
				
		li $v0, 4
		la $a0, inst2
		syscall
				
		li $v0, 4
		la $a0, inst3
		syscall
		
		li $v0, 4
		la $a0, greeting1
		syscall
		
		li $v0, 5
		syscall
		addi $t0, $v0, 0
		
		bne $t0, $zero, newgame
		j quit
		
# In the worst case, there will be 12 paired of moves, means that 24 locations has been filled and there's still no winner.
# The 25th moves of Player1 will end the game whether there is a winner or not.
# Sequentially calling procedure to process the game

        newgame:li $v0, 4
		la $a0, separate
		syscall
	
	# Handle 1st pair of move separately				
      		jal Draw_board
		jal Move1_P1
		jal Draw_board
		jal Undo_Op
		beq $v0, $zero, Move1.2
		jal Draw_board
		jal Move1_P1
		jal Draw_board
		jal Update_backup
	Move1.2:jal Move1_P2
		jal Draw_board
		jal Undo_Op
		beq $v0, $zero, Move2
		jal Draw_board
		jal Move1_P2
		jal Draw_board
		jal Update_backup
	
	# From 2nd pair of move to 12th pair of move needs 11 loops 
	Move2:
		addi $t1, $zero, 11		
		addi $t0, $zero, 0
	playingLoop:	
		beq $t0, $t1, lastMove
						
		jal P1_Move
		jal Draw_board
		jal Undo_Op
		beq $v0, $zero, player2
		jal Draw_board
		jal P1_Move
		jal Draw_board
		jal Update_backup
	player2:jal P2_Move
		jal Draw_board
		jal Undo_Op
		beq $v0, $zero, nextLoop
		jal Draw_board
		jal P2_Move
		jal Draw_board
		jal Update_backup
		
       nextLoop:addi $t0, $t0, 1
       		j playingLoop	
		
       # Last move
       lastMove:jal P1_Move
       # After all 25 cells have been filled but no winner is found, it's a drawn game	
		jal Draw_board

		li $v0, 4
		la $a0, Drawn
		syscall
		
       replay:	jal resetBoard
		jal resetBack_up
		
		li $v0, 4
		la $a0, Newgame
		syscall
		
		li $v0, 5
		syscall
		addi $t0, $v0, 0
		
		beq $t0, $zero, end_game
		j newgame

       quit:	li $v0, 4
		la $a0, noplay
		syscall
			
       end_game:li $v0, 10
		syscall
#################################   DRAW BOARD PROCEDURE   ################################################
###########################################################################################################
Draw_board:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $t0, board   	# Store address of the board
		lw $t3, size		# Stopping loop conditional
		addi $t1, $zero, 0  	# Counter to traverse through each row
		
		li $v0, 4
		la $a0, newline
     		syscall
		
       draw_loop_row:
  		beq $t1, $t3, end_draw_board
		sll $t4, $t1, 2
		add $t4, $t4, $t0		
		lw $t5, 0($t4)		# base address of the row
		
		li $v0, 4
		la $a0, spaceRow
		syscall
		
		addi $t2, $zero, 0	# Counter to traverse through each column
      draw_loop_column:
		beq $t2, $t3, draw_next_row 
		sll $t6, $t2, 2
		add $s0, $t5, $t6	
		lw $t7, 0($s0)      	# $t7 contain the data at board[x][y]
		
		addi $a0, $t7, 0
		li $v0, 11
		syscall
		
		li $v0, 4
		la $a0, space
		syscall
		
		addi $t2, $t2, 1
		j draw_loop_column
		              
     draw_next_row: 
		li $v0, 4
		la $a0, newline
     		syscall
		
		addi $t1, $t1, 1
		j draw_loop_row
		
    end_draw_board: 
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
#################################   RESET BOARD PROCEDURE   ################################################
############################################################################################################
resetBoard:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $t0, board   	# Store address of the board
		lw $t3, size		# Stopping loop conditional
		addi $t1, $zero, 0  	# Counter to traverse through each row
	
      resetBoard_loop_row:
		beq $t1, $t3, end_resetBoard
		sll $t4, $t1, 2
		add $t4, $t4, $t0		
		lw $t5, 0($t4)		# base address of the row
		
		addi $t2, $zero, 0	# Counter to traverse through each column
      resetBoard_loop_column:
		beq $t2, $t3, resetBoard_next_row 
		sll $t6, $t2, 2
		add $s0, $t5, $t6	# address of board[x][y]
		
		addi $t7, $zero, '-'
		sw $t7, 0($s0)      
		
		addi $t2, $t2, 1
		j resetBoard_loop_column
		              
      resetBoard_next_row: 
		addi $t1, $t1, 1
		j resetBoard_loop_row
		
      end_resetBoard: 
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
#################################   RESET BACK-UP PROCEDURE   ##############################################
############################################################################################################
resetBack_up:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $t0, back_up   	# Store address of the board
		lw $t3, size		# Stopping loop conditional
		addi $t1, $zero, 0  	# Counter to traverse through each row
	
        resetBack_up_loop_row:
		beq $t1, $t3, end_resetBack_up
		sll $t4, $t1, 2
		add $t4, $t4, $t0		
		lw $t5, 0($t4)		# base address of the row
		
		addi $t2, $zero, 0	# Counter to traverse through each column
        resetBack_up_loop_column:
		beq $t2, $t3, resetBack_up_next_row 
		sll $t6, $t2, 2
		add $s0, $t5, $t6	# address of board[x][y]
		
		addi $t7, $zero, '-'
		sw $t7, 0($s0)      
		
		addi $t2, $t2, 1
		j resetBack_up_loop_column
		              
        resetBack_up_next_row: 
		addi $t1, $t1, 1
		j resetBack_up_loop_row
		
        end_resetBack_up: 
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
#######################################   UNDO PROCEDURE   ################################################
###########################################################################################################
Undo_Op:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $t0, board   	# Store address of the board
		la $t1, back_up		# Store address of the temparary board 
		lw $t4, size		# Stopping loop conditional

		li $v0, 4
		la $a0, Undo
		syscall
		
		li $v0, 5
		syscall
		addi $t5, $v0, 0
	#If players agree to undo, copy data from back-up to board
		beq $t5, $zero, update_back_up
		
		addi $t2, $zero, 0  	# Counter to traverse through each row
        undo1_loop_row:	
		beq $t2, $t4, end_undo
		sll $t6, $t2, 2
		add $t6, $t6, $t1
		lw $t7, 0($t6)		# Base address of row of back-up
		
		sll $t6, $t2, 2
		add $t6, $t6, $t0
		lw $t8, 0($t6)		# Base address of row of board
		  
		addi $t3, $zero, 0	# Counter to traverse through each column
		
        undo1_loop_column:
		beq $t3, $t4, undo1_next_row
		sll $t9, $t3, 2
		add $t9, $t9, $t7
		lw $s0, 0($t9) 		# $s0 contain data in back_up[x][y]
		
		sll $t9, $t3, 2
		add $t9, $t9, $t8
		sw $s0, 0($t9)		# Undo board[x][y]
		
		addi $t3, $t3, 1
		j undo1_loop_column
        undo1_next_row:
		addi $t2, $t2, 1		
		j undo1_loop_row
      # Else update back-up with data in board
      update_back_up:
		jal Update_backup
		
      end_undo:	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
###################################   UPDATE BACK-UP BOARD PROCEDURE   ####################################
###########################################################################################################	
Update_backup:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		la $t0, board   	# Store address of the board
		la $t1, back_up		# Store address of the temparary board 
		lw $t4, size		# Stopping loop conditional
		
		addi $t2, $zero, 0  	# Counter to traverse through each row
        update_loop_row:
		beq $t2, $t4, end_Update
		
		sll $t6, $t2, 2
		add $t6, $t6, $t0
		lw $t7, 0($t6)		# Base address of row of board
		
		sll $t6, $t2, 2
		add $t6, $t6, $t1
		lw $t8, 0($t6)		# Base address of row of back-up
		  
		addi $t3, $zero, 0	# Counter to traverse through each column		
       update_loop_column:
		beq $t3, $t4, update_next_row
		
		sll $t9, $t3, 2
		add $t9, $t9, $t7
		lw $s0, 0($t9) 		# $s0 contain data in board[x][y]
		
		sll $t9, $t3, 2
		add $t9, $t9, $t8
		sw $s0, 0($t9)		# Update back_up[x][y]
		
		addi $t3, $t3, 1
		j update_loop_column
      update_next_row:
		addi $t2, $t2, 1		
		j update_loop_row
		
     end_Update:	
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
##############################   PROCEDURE SET TO GET AND PROCESS INPUT   #################################
###########################################################################################################

####################################   HANDLE 1st MOVE OF PLAYER 1  #######################################
Move1_P1:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
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
     								
     # Check if 1st move in the central point
     checkMid1:	addi $t0, $zero, 2
		bne $a1, $t0, next1
		bne $a2, $t0, next1
		
		# If the move is on the central point, enter again
		li $v0, 4
		la $a0, Warn1
		syscall
		j ReMove1_P1
	
     # Else update board[x][y] with 'X'
     next1:	jal P1_Play
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
####################################   HANDLE 1st MOVE OF PLAYER 2  ########################################
Move1_P2:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
    # Player2's input
    ReMove1_P2:	li $v0, 4
		la $a0, Input2
		syscall
		
		# Player2's X_coord
		li $v0, 5
		syscall
		addi $a1, $v0, -1  # Adjust to fix with array index start from 0
		
		# Player2's Y_coord
		li $v0, 5
		syscall
		addi $a2, $v0, -1  # Adjust to fix with array index start from 0
     
     # Check if values are out of range
    		addi $t0, $zero, 4
    		slt $t1, $t0, $a1
    		bne $t1, $zero, outRange2
    		
    		slt $t1, $a1, $zero
    		bne $t1, $zero, outRange2
    		
    		slt $t1, $t0, $a2
    		bne $t1, $zero, outRange2
    		
    		slt $t1, $a2, $zero
    		bne $t1, $zero, outRange2
    		j checkMid2
    		
    outRange2:	li $v0, 4
		la $a0, Warn2
		syscall
		j ReMove1_P2		
     						
     # Check if 1st move in the central point
     checkMid2:	addi $t0, $zero, 2
		bne $a1, $t0, next3
		bne $a2, $t0, next3
		
		# If the move is on the central point, enter again
		li $v0, 4
		la $a0, Warn1
		syscall
		j ReMove1_P2
		
     # Else update board[x][y] with 'O'
     next3:	jal P2_Play
	
		# If P2_Play procedure returns -1, it indicates that cell has been occupied
		addi $t0, $zero, -1
		bne $v0, -1, next4 
		
		# Then ask to choose again
		li $v0, 4
		la $a0, Warn3
		syscall
		j ReMove1_P2
		
		# Else board[x][y] has successfully upfated to 'O'
     next4:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
####################################   HANDLE FROM 2nd MOVE OF PLAYER 1  ######################################																		
P1_Move:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
     # Player1's input		
     ReP1_Move:	li $v0, 4
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
    		bne $t1, $zero, outRange3
    		
    		slt $t1, $a1, $zero
    		bne $t1, $zero, outRange3
    		
    		slt $t1, $t0, $a2
    		bne $t1, $zero, outRange3
    		
    		slt $t1, $a2, $zero
    		bne $t1, $zero, outRange3
    		j play1
    		
    outRange3:	li $v0, 4
		la $a0, Warn2
		syscall
		j ReP1_Move		
     						
     play1:	jal P1_Play
		
     # If P1_Play procedure returns -1, it indicates that cell has been occupied
		addi $t0, $zero, -1
		bne $v0, $t0, continue1  
		
     # Else enter again
		li $v0, 4
		la $a0, Warn3
		syscall
		j ReP1_Move
	
     continue1:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
####################################   HANDLE FROM 2nd MOVE OF PLAYER 2  ######################################		
P2_Move:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
     # Player2's input		
     ReP2_Move:	li $v0, 4
		la $a0, Input2
		syscall
		
		# Player2 's X_coord
		li $v0, 5
		syscall
		addi $a1, $v0, -1  # Adjust to fix with array index start from 0
		
		# Player2 's Y_coord
		li $v0, 5
		syscall
		addi $a2, $v0, -1  # Adjust to fix with array index start from 0
    
     # Check if values are out of range
    		addi $t0, $zero, 4
    		slt $t1, $t0, $a1
    		bne $t1, $zero, outRange4
    		
    		slt $t1, $a1, $zero
    		bne $t1, $zero, outRange4
    		
    		slt $t1, $t0, $a2
    		bne $t1, $zero, outRange4
    		
    		slt $t1, $a2, $zero
    		bne $t1, $zero, outRange4
    		j play2
    		
    outRange4:	li $v0, 4
		la $a0, Warn2
		syscall
		j ReP2_Move	
    				
    play2:	jal P2_Play
		
    # If P2_Play procedure returns -1, it indicates that cell has been occupied
		addi $t0, $zero, -1
		bne $v0, -1, continue2 
		
    # Then enter again
		li $v0, 4
		la $a0, Warn3
		syscall
		j ReP2_Move
		
    continue2:	lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
############################################   PROCEDURE SET TO PLACE A MOVE   ############################################
###########################################################################################################################
# Procedure P1_Play: Update board[x][y] = 'X', return 0 if success, 1 if P1 wins, -1 if the location is previously occupied
P1_Play:
		addi $sp, $sp, -12 
		sw $ra, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		
		# Fetch the data at board[x][y] to check if it is occupied or not
		la $t0, board      # Store address of board
		sll $t1, $a1, 2
		add $t1, $t1, $t0
		lw $t2, 0($t1)     # base address of the row 	
	
		sll $t1, $a2, 2
		add $s0, $t1, $t2  # base address of board[x][y]
		lw $t2, 0($s0)		
		
		# If board[x][y] != '-', this mean it has been previously occupied
		addi $t5, $zero, '-'
		bne $t2, $t5, Occupied   
		# Else board[x][y] = 'X'
		addi $t3, $zero, 'X'	  
		sw $t3, 0($s0) 
		
		# Check for winner
		jal Result
		
		# Procedure Result return 1 if a winner is found
		addi $t4, $zero, 1
		beq $v0, $t4, P1_Winner
		
		# Else return 0 success updating board[x][y] with no winner
		addi $v0, $zero, 0  
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra
		
P1_Winner:		
		jal Draw_board
		
		li $v0, 4
		la $a0, P1_Win
		syscall
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		
		j replay

# Procedure P2_Play: Update board[x][y] = 2, return 0 if success, 1 if P2 wins, -1 if error		
P2_Play:
		addi $sp, $sp, -12 
		sw $ra, 0($sp)
		sw $a1, 4($sp)
		sw $a2, 8($sp)
		
		# Fetch the data at board[x][y] to check if it is occupied or not
		la $t0, board      # Store address of board
		sll $t1, $a1, 2
		add $t1, $t1, $t0
		lw $t2, 0($t1)     # base address of the row 	
	
		sll $t1, $a2, 2
		add $s0, $t1, $t2  # base address of board[x][y]
		lw $t2, 0($s0)
		
		# If board[x][y] != '-', this mean it has been previously occupied
		addi $t5, $zero, '-'
		bne $t2, $t5, Occupied   
		# Else board[x][y] = 'O'
		addi $t3, $zero, 'O'	       
		sw $t3, 0($s0) 
		
		# Check for winner
		jal Result
		
		# Procedure Result return 1 if a winner a found
		addi $t4, $zero, 1
		beq $v0, $t4, P2_Winner
		# Else return 0, success updating board[x][y] with no winner
		addi $v0, $zero, 0  
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra
		

P2_Winner:		
		jal Draw_board
		
		li $v0, 4
		la $a0, P2_Win
		syscall
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		
		j replay

Occupied:
		addi $v0, $zero, -1	# Return -1 to require players enter again
		
		lw $ra, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra
#################################   PROCEDURE TO FIND OUT WINNER   ####################################
#######################################################################################################
# Result procedure check if the lastest move of any players cause a win, return 1 if there is a winner, otherwise 0
Result:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		jal checkRow0
		jal checkRow1
		jal checkRow2
		jal checkRow3
		jal checkRow4
	 
		jal checkCol0
		jal checkCol1
		jal checkCol2
		jal checkCol3
		jal checkCol4
		
		# From top left to right bottom, there are 5 diagonals with more than 3 cells
		jal checkLeftDiag0
		jal checkLeftDiag1
		jal checkLeftDiag2
		jal checkLeftDiag3
		jal checkLeftDiag4
		
		# From top right to left bottom, there are also 5 diagonals with more than 3 cells
		jal checkRightDiag0
		jal checkRightDiag1
		jal checkRightDiag2
		jal checkRightDiag3
		jal checkRightDiag4
		
		# After checking all rows, columns and diagonals if there is no winner return 0
		addi $v0, $zero, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra

checkRow0:
		la $t0, board		# Address of board
		lw $t1, 0($t0)		# Address of row 0
		lw $t2, 0($t1)		# board[0][0]
		lw $t3, 4($t1)		# board[0][1]
		lw $t4, 8($t1)		# board[0][2]
		lw $t5, 12($t1)		# board[0][3]
		lw $t6, 16($t1)		# board[0][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRow1:
		la $t0, board		# Address of board
		lw $t1, 4($t0)		# Address of row 1
		lw $t2, 0($t1)		# board[1][0]
		lw $t3, 4($t1)		# board[1][1]
		lw $t4, 8($t1)		# board[1][2]
		lw $t5, 12($t1)		# board[1][3]
		lw $t6, 16($t1)		# board[1][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRow2:
		la $t0, board		# Address of board
		lw $t1, 8($t0)		# Address of row 2
		lw $t2, 0($t1)		# board[2][0]
		lw $t3, 4($t1)		# board[2][1]
		lw $t4, 8($t1)		# board[2][2]
		lw $t5, 12($t1)		# board[2][3]
		lw $t6, 16($t1)		# board[2][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRow3:
		la $t0, board		# Address of board
		lw $t1, 12($t0)		# Address of row 3
		lw $t2, 0($t1)		# board[3][0]
		lw $t3, 4($t1)		# board[3][1]
		lw $t4, 8($t1)		# board[3][2]
		lw $t5, 12($t1)		# board[3][3]
		lw $t6, 16($t1)		# board[3][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRow4:
		la $t0, board		# Address of board
		lw $t1, 16($t0)		# Address of row 4
		lw $t2, 0($t1)		# board[4][0]
		lw $t3, 4($t1)		# board[4][1]
		lw $t4, 8($t1)		# board[4][2]
		lw $t5, 12($t1)		# board[4][3]
		lw $t6, 16($t1)		# board[4][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkCol0:
		la $t0, board		# Adrres of board
		
		lw $t1, 0($t0)
		lw $t2, 0($t1)		# board[0][0]
		
		lw $t1, 4($t0)
		lw $t3, 0($t1)		# board[1][0]
		
		
		lw $t1, 8($t0)
		lw $t4, 0($t1)		# board[2][0]
		
		
		lw $t1, 12($t0)
		lw $t5, 0($t1)		# board[3][0]
		
		
		lw $t1, 16($t0)
		lw $t6, 0($t1)		# board[4][0]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkCol1:
		la $t0, board		# Adrres of board
		
		lw $t1, 0($t0)
		lw $t2, 4($t1)		# board[0][1]
		
		lw $t1, 4($t0)
		lw $t3, 4($t1)		# board[1][1]
		
		
		lw $t1, 8($t0)
		lw $t4, 4($t1)		# board[2][1]
		
		
		lw $t1, 12($t0)
		lw $t5, 4($t1)		# board[3][1]
		
		
		lw $t1, 16($t0)
		lw $t6, 4($t1)		# board[4][1]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkCol2:
		la $t0, board		# Adrres of board
		
		lw $t1, 0($t0)
		lw $t2, 8($t1)		# board[0][2]
		
		lw $t1, 4($t0)
		lw $t3, 8($t1)		# board[1][2]
		
		
		lw $t1, 8($t0)
		lw $t4, 8($t1)		# board[2][2]
		
		
		lw $t1, 12($t0)
		lw $t5, 8($t1)		# board[3][2]
		
		
		lw $t1, 16($t0)
		lw $t6, 8($t1)		# board[4][2]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkCol3:
		la $t0, board		# Adrres of board
		
		lw $t1, 0($t0)
		lw $t2, 12($t1)		# board[0][3]
		
		lw $t1, 4($t0)
		lw $t3, 12($t1)		# board[1][3]
		
		
		lw $t1, 8($t0)
		lw $t4, 12($t1)		# board[2][3]
		
		
		lw $t1, 12($t0)
		lw $t5, 12($t1)		# board[3][3]
		
		
		lw $t1, 16($t0)
		lw $t6, 12($t1)		# board[4][3]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkCol4:
		la $t0, board		# Adrres of board
		
		lw $t1, 0($t0)
		lw $t2, 16($t1)		# board[0][4]
		
		lw $t1, 4($t0)
		lw $t3, 16($t1)		# board[1][4]
		
		
		lw $t1, 8($t0)
		lw $t4, 16($t1)		# board[2][4]
		
		
		lw $t1, 12($t0)
		lw $t5, 16($t1)		# board[3][4]
		
		
		lw $t1, 16($t0)
		lw $t6, 16($t1)		# board[4][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra

checkLeftDiag0:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 0($t1)		# board[0][0]
		
		lw $t1, 4($t0)
		lw $t3, 4($t1)		# board[1][1]
		
		lw $t1, 8($t0)
		lw $t4, 8($t1)		# board[2][2]
		
		lw $t1, 12($t0)
		lw $t5, 12($t1)		# board[3][3]
		
		lw $t1, 16($t0)
		lw $t6, 16($t1)		# board[4][4]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkLeftDiag1:
		la $t0, board
		
		lw $t1, 4($t0)
		lw $t2, 0($t1)		# board[1][0]
		
		lw $t1, 8($t0)
		lw $t3, 4($t1)		# board[2][1]
		
		lw $t1, 12($t0)
		lw $t4, 8($t1)		# board[3][2]
		
		lw $t1, 16($t0)
		lw $t5, 12($t1)		# board[4][3]
		
		# There are 2 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkLeftDiag2:
		la $t0, board
		
		lw $t1, 8($t0)
		lw $t2, 0($t1)		# board[2][0]
		
		lw $t1, 12($t0)
		lw $t3, 4($t1)		# board[3][1]
		
		lw $t1, 16($t0)
		lw $t4, 8($t1)		# board[4][2]
		
		# There is only 1 combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkLeftDiag3:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 4($t1)		# board[0][1]
		
		lw $t1, 4($t0)
		lw $t3, 8($t1)		# board[1][2]
		
		lw $t1, 8($t0)
		lw $t4, 12($t1)		# board[2][3]
		
		lw $t1, 12($t0)
		lw $t5, 16($t1)		# board[3][4]
		
		# There are 2 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkLeftDiag4:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 8($t1)		# board[0][2]
		
		lw $t1, 4($t0)
		lw $t3, 12($t1)		# board[1][3]
		
		lw $t1, 8($t0)
		lw $t4, 16($t1)		# board[2][4]
		
		# There is only 1 combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRightDiag0:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 16($t1)		# board[0][4]
		
		lw $t1, 4($t0)
		lw $t3, 12($t1)		# board[1][3]
		
		lw $t1, 8($t0)
		lw $t4, 8($t1)		# board[2][2]
		
		lw $t1, 12($t0)
		lw $t5, 4($t1)		# board[3][1]
		
		lw $t1, 16($t0)
		lw $t6, 0($t1)		# board[4][0]
		
		# There are 3 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		and $t9, $t4, $t5	
		and $t9, $t9, $t6
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		beq $t9, $s0, returnWinner
		beq $t9, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRightDiag1:
		la $t0, board
		
		lw $t1, 4($t0)
		lw $t2, 16($t1)		# board[1][4]
		
		lw $t1, 8($t0)
		lw $t3, 12($t1)		# board[2][3]
		
		lw $t1, 12($t0)
		lw $t4, 8($t1)		# board[3][2]
		
		lw $t1, 16($t0)
		lw $t5, 4($t1)		# board[4][1]
		
		# There are 2 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRightDiag2:
		la $t0, board
		
		lw $t1, 8($t0)
		lw $t2, 16($t1)		# board[2][4]
		
		lw $t1, 12($t0)
		lw $t3, 12($t1)		# board[3][3]
		
		lw $t1, 16($t0)
		lw $t4, 8($t1)		# board[4][2]
		
		# There is only 1 combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRightDiag3:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 12($t1)		# board[0][3]
		
		lw $t1, 4($t0)
		lw $t3, 8($t1)		# board[1][2]
		
		lw $t1, 8($t0)
		lw $t4, 4($t1)		# board[2][1]
		
		lw $t1, 12($t0)
		lw $t5, 0($t1)		# board[3][0]
		
		# There are 2 posible combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		and $t8, $t3, $t4	
		and $t8, $t8, $t5
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		beq $t8, $s0, returnWinner
		beq $t8, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
		
checkRightDiag4:
		la $t0, board
		
		lw $t1, 0($t0)
		lw $t2, 8($t1)		# board[0][2]
		
		lw $t1, 4($t0)
		lw $t3, 4($t1)		# board[1][1]
		
		lw $t1, 8($t0)
		lw $t4, 0($t1)		# board[2][0]
		
		# There is only 1 combination
		# If 3 consecutive cells are all 'X' or 'O', the result will be the same type
		and $t7, $t2, $t3	
		and $t7, $t7, $t4
		
		addi $s0, $zero, 'X'
		addi $s1, $zero, 'O'
		# If a winner is found, return 1
		beq $t7, $s0, returnWinner	
		beq $t7, $s1, returnWinner
		# Else return 0
		addi $v0, $zero, 0		
		
		jr $ra
returnWinner:
		addi $v0, $zero, 1
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
###########################################################################################################