.text
main:
		li 			$a0 -8264
		li 			$a1, 7451
		jal 			multi							# Answer in $v1
		j   			END

multi:
		addi		$sp, $sp, -4					# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)					# Store $ra value
		
		# Temporal Registers: $t0, $t1

		jal			signSwitch					# Function to switch the signs
		
		beqz		$a1, exitFunctionM			# $a1 = 0  Return 0
		move 		$t1, $a0						# Add auxiliar
			
		loopM:									# Add loop
			subi		$a1, $a1, 1				# b = b - 1
			blez		$a1, exitLoopM			# if b == 0 -> break
			add			$a0, $a0, $t1			# a = a + aux
			j 			loopM					# loop
		
		exitLoopM:
			beqz		$t0, return				# Sign Switch (Case: (-) (+) or (-)(+))
			add			$t1, $a0, $a0
			sub			$a0, $a0, $t1
		
		return:
			beqz		$a0, return0			# If a == 0 return 0
			move		$v1, $a0				# move the answet to $v1
			
		return0:
			j 			exitFunctionM

		exitFunctionM:							# Used registers: $t0 and $t1
			lw 			$ra, 0($sp)				# Store $ra value
			addi		$sp, $sp, 4				# Asigns one space in the stack to store $ra value
			li			$t1 0	
			jr 			$ra
				
signSwitch:
		# Sign Cases
		bltz 		$a0, casemM
		bltz 		$a1, caseMm
		j 			continue					# Case ( +)( + )
		casemM:
			# Case ( - ) ( + )
			bltz 		$a1, casemm	
			add 		$t1, $a0, $a0
			sub 		$a0, $a0, $t1		
			li 			$t0, 1 					# Control Register
			j 			continue
		
		casemm:
			# Case ( - ) ( - )
			add 		$t1, $a0, $a0
			sub 		$a0, $a0, $t1
			add 		$t1, $a1, $a1
			sub 		$a1, $a1, $t1
			j			continue
		
		caseMm: 
			# Case ( + ) and ( - )
			add 		$t1, $a1, $a1
			sub 		$a1, $a1, $t1
			li 			$t0, 1 					# Control Register

		continue:
			jr			$ra	
			
END:
		li 			$v0, 10	
 		syscall
