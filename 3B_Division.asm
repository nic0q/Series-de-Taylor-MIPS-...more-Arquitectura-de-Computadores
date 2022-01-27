.data
	f1:			.float 0.1					# For "multiply" units without mul
	f2:			.float 0.01					# For "multiply" hundreds without mul
	one:		.float 1						# Auxiliar to load 1 in coproc1
.text
main:
		li 			$a0, -97					# Number 1
		li 			$a1,	 -894			# Number 2
		jal 			division					# The answer will be store $f0 (quotient) COPROC 1
		j   			END

multi:
		addi		$sp, $sp, -4				# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)				# Store $ra value
		
		jal			signSwitch				# Procedure Sign Switch
		
		beqz		$a1, exitFunctionM		# $a1 = 0  Return 0
		move 		$t1, $a0					# Add auxiliar
			
		loopM:								# Add loop
			subi		$a1, $a1, 1			# b = b - 1
			blez		$a1, exitLoopM		# if b == 0 -> break
			add			$a0, $a0, $t1		# a = a + aux
			j 			loopM				# loop
		
		exitLoopM:
			beqz		$t0, return			# Sign Switch (Case: (-) (+) or (-)(+))
			add			$t1, $a0, $a0
			sub			$a0, $a0, $t1
		
		return:
			beqz		$a0, return0		# If a == 0 return 0
			move		$v1, $a0			# move the answet to $v1
			
		return0:
			j 			exitFunctionM

		exitFunctionM:						# Used registers: $t0 and $t1
			lw 			$ra, 0($sp)			# Store $ra value
			addi		$sp, $sp, 4			# Asigns one space in the stack to store $ra value
			li			$t1 0	
			jr 			$ra
				
signSwitch:
		# Sign Cases
		bltz 		$a0, casemM
		bltz 		$a1, caseMm
		j 			continue				# Case ( +)( + )
		
		casemM:
			# Case ( - ) ( + )
			bltz 		$a1, casemm	
			add 		$t1, $a0, $a0
			sub 		$a0, $a0, $t1		
			li 			$t0, 1 				# Control Register
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
			li			$t1, 0
			jr			$ra	
		
division:
		addi		$sp, $sp, -4					# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)					# Store $ra value
		jal			signSwitch					# Function to choose the signs	($t0)
		move 		$s3, $a0					# Auxiliar registers to store the original parameters $a0
		move 		$s4, $a1					# Auxiliar registers to store the original parameters $a1

		jal 			integerDiv
		move		$s0, $v1					# Integer Part store in $s0

		# CASE 1: Proper Division: a > b, but remainder != 0
		ble 			$s3, $s4, decimalPart
		beqz		$a0, properDiv
	
		# CASE 2: Improper Division: a < b
		j			decimalPart
	
		properDiv:
			beqz		$t0, exit1			# Sign switch
			add			$t1, $v1, $v1
			sub			$v1, $v1, $t1
		
			exit1:
			li 			$t1, 0x10010000		# Initialize an array "arr[3]" in 0x10010000
			sw			$v1, ($t1)			# Store in $f0, $f1, $f2
		
			lwc1		$f0, 0($t1)			# Converts to Decimal
			cvt.s.w 		$f0, $f0
		
			lw 			$ra, 0($sp)	
			sw			$zero 	0($sp)		
			addi		$sp		$sp,4
			li			$t1 0
			jr			$ra
		
decimalPart:								# Division  Algorithm, Units in $s3, Hundreds in $s4
											# Remainder in $a0		# 10 * 1
		beqz		$a0 zeroU
		li			$a1, 10	
									
		lwc1		$f3, f1					# Store 0.10  in $f3
		lwc1		$f4, f2					# Store 0.01  in $f4
		lwc1		$f21,one				# Store 1  in $f21

		jal 			multi

		beqz		$t0, j1					# Sign switch if one is negative
		add 		$t1, $v1, $v1	
		sub 		$v1, $v1, $t1	
		j1:	
		move		$a0,$v1					# Move result of multi $v1 to parameter $a0
		move		$a1, $s4				# Move $s4 original number to parameter $a1
		li			$v1, 0					# Empty $v1 register
		jal 			integerDiv				# Call integerDiv to get the decimal units
		
		move		$s1, $v1					# Gets the FIRST DECIMAL (UNITS)		
		j			exU
		zeroU:
		move		$s2, $zero
		exU:
		beqz		$a0 zeroC
		li			$a1, 10
		jal 			multi	
	
		beqz		$t0, j2		
					# Sign switch if one is negative
		add 		$t1, $v1, $v1
		sub 		$v1, $v1, $t1	
		j2:

		move		$a0,$v1					# Move result of multi $v1 to parameter $a0
		move		$a1, $s4				# Move $s4 original number to parameter $a1
		li			$v1, 0					# Empty $v1 register
		jal 			integerDiv				# Call integerDiv to get the decimal units
		move		$s2, $v1				# Gets the FIRST DECIMAL (HUNDREDS)
		j			exC
		zeroC:
		move		$s2, $zero
		exC:
		# Registros usados: $s1, $s2, $s3, $s4
		
decimalCoproc:
		# Store in memory
		li 			$t1, 0x10010000			# Initialize an array "arr[3]"
		sw			$s0, 0($t1)				# address arr [ 0 ]	# Integer Part
		sw			$s1, 4($t1)				# address arr [ 1 ]	# Decimal 1
		sw			$s2, 8($t1)				# address arr [ 2 ]	# Decimal 2
	
		# Store in $f0, $f1, $f2
		lwc1		$f0, 0($t1)
		lwc1		$f1, 4($t1)		
		lwc1		$f2, 8($t1)	
	
		# Converts to Decimal
		cvt.s.w 		$f0, $f0
		cvt.s.w 		$f1, $f1
		cvt.s.w 		$f2, $f2
	
		# Move for execute the Coproc function
		movf.s		$f10, $f4
		movf.s		$f11, $f2
		move		$t9, $s2

		jal decimalMult							# get the hundreds decimal part (0, 01) * remainder 2  (hundreds)
	
		# Move for execute the Coproc function
		movf.s		$f10, $f3
		movf.s		$f11, $f1
		move		$t9, $s1

		jal decimalMult							# get the units decimal part (0, 01) * remainder 2  (units)
	
		beqz		$t0, notSwitch				# Sign Switch
		add.s		$f12, $f0, $f0
		sub.s		$f0, $f0, $f12
	
		notSwitch:								# Empy memory
			sw			$zero, 0($t1)				# address arr [ 0 ]	# 0
			sw			$zero, 4($t1)				# address arr [ 1 ]	# 0
			sw			$zero, 8($t1)				# address arr [ 2 ]	# 0
	
		lw 			$ra, 0($sp)		
		li			$t1 0		
		sw			$zero, 0($sp)
		add 		$sp, $sp, 4					# Empty stack
		jr			$ra					

# $f1 "multiply" with $f3
# $f2 "multiply" with $f4
# So the decimal function recieve $f11: Integer and $f10 Decimal
decimalMult:								#  Recieve $f10 y $f11 parameters
		movf.s 		$f9, $f10				# $f9: Decimal Part
		move		$t8, $t9					# $t8: Integer Part
		beqz		$t8, emptyFunctionDc	# $t8 = 0  Return 0
		
		loopD:								# while($t8 != 0 )
			subi		$t8, $t8, 1			# $t8 = $t8 - 1
			blez		$t8,	exitLoopD		# break
			add.s		$f10, $f10, $f9		# $f10 = $f10 + aux($f9) "Original $f10
			j 			loopD
				
		exitLoopD:
			add.s		$f0,$f10, $f0		# Add the decimal part to integer part (Store in $f0)
			
		emptyFunctionDc:
			li 			$t9 		0			# Empty temporal registers
			jr			$ra					# Return the answer in $f10 coproc register

integerDiv:
		beqz 		$a1, exitFunctionD		# If $a1 = 0 the algorithm can't execute
		beqz 		$a0, exitFunctionD		# If $a0 = 0 return 0
		recursiveDiv:
			subu		$sp, $sp, 12			# Stack space assignement
			sw 			$ra, ($sp)
			sw			$s0, 4($sp)
			sw			$s1,  8($sp)
		
			sub  		$t1, $a0,$a1			# Base Case
			bltz 		$t1,divDone			#  If (a + b<= 1)	
						
			move 		$s1, $a1		
			move 		$s0, $a0

			sub 		$a0, $a0, $a1		# a = (a - b)
			jal 			recursiveDiv
			addi  		$v1,$v1 ,1 			# (v1 += 1)
		
		divDone:
			lw 			$ra 	0($sp)		# Empty the stack
			sw			$zero 	0($sp)				
			lw			$s0		4($sp)
			sw			$zero 	4($sp)
			lw			$s1  	8($sp)
			sw			$zero	8($sp)
			addu		$sp		$sp,12
	
		exitFunctionD:	
			jr 			$ra					# return
			
END:
		li 		$v0, 10
		syscall	
