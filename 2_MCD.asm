# $sx => variables globales
# $tx => variables locales
.data
	answerMessage: .asciiz "The MCD is : "
	answer: .word 0
.text
main:
	# $a0 the numbers
		li			$a0, 980			# Number 1
		li			$a1, 80				# Number 2	
		abs			$a0 $a0			# The algorith
		abs			$a1 $a1
		jal 			euclides			# Result in $v1 register	

		sw			$v1, answer			# Print Answer
    		li	 		$v0, 4
		la	 		$a0,  answerMessage
		syscall
		li			$v0, 1
		lw			$a0, answer
		syscall	
		j 			EXIT
	
	
euclides:
     		subu 		$sp, $sp, 12			# Store in stack
     		sw   		$ra, 0($sp)
     		sw   		$s0, 4($sp)
    		sw   		$s1,  8($sp)
  		
     		beqz 		$a1 	 mcdDone	     	# Base Case
    
     		# Recursive step
    		move 		$s0, $a0
    		move 		$s1, $a1
     		div 			$a0, $a1
    		mfhi 		$t3
    		add 		$a0,$a1, $zero
     		add	 		$a1, $t3, $zero

   		jal 			euclides
    		move 		$v1, $a0			# Move answer of $a0 parameter to $v1

		mcdDone:
    			lw	 		$ra, ($sp)
    			sw			$zero ($sp)
    			lw	 		$s0, 4($sp)
    			lw	 		$zero, 4($sp)
    			lw   		$s1,  8($sp)
    			lw	 		$zero, 4($sp)
    			addu  		$sp, $sp, 12		# Stack Empty
			li 			$t3, 0   			# Local variables empty
			jr 			$ra				# return to main
    
EXIT: 
	
		li 			$v0, 10					# Exit the program
		syscall

	
    
