.data
		f1:			.float 0.1					# For "multiply" units without mul
		f2:			.float 0.01					# For "multiply" hundreds without mul
		one:		.float 1						# Auxiliar to load 1 in coproc1
		f10:			.float 10						# Load 10 to multiply units and hundreds
		inputX: 		.asciiz "Please input a x for taylor ln(x+1): "
		number1: 	.asciiz " taylor ln(x+1) de Orden "	
		answMsg: 	.asciiz   " el resulta es "
		jumpLine:	.asciiz   " \n"	
 .text
 main:
 		jal			getNumber
 		jal			loadUnitsAndHundreds
 		jal 			taylorLn				# Returns in $v1
 		j   			END					# End proccess
 
loadUnitsAndHundreds:
		lwc1		$f10, f1					# Store 0.10  in $f10
		lwc1		$f11, f2					# Store 0.01  in $f11		
		lwc1		$f9, f10					# Store 10 in $f9
		lwc1		$f21,one				# Store 1  in $f21
		jr			$ra						# return
		 				
 getNumber:
 		li	 		$v0,  4				# Send the first message
		la	 		$a0, inputX
		syscall
		li	 		$v0, 5				# Gets number1
		syscall
		addi		$a0 $a0 1
		move 		$a0, $v0 			# Store in $a0
		jr			$ra
		
taylorLn:
 		li 			$a3, 0x10010000	
 		move		$s5, $a0				# Aux " x "
 		sw			$ra, 80($a3)			# Store $ra to return
		
 		li			$s6, 11					# Order 11 default
 		li			$s7, 2					# Actual "n" [+1 -3 +5 -7 +9 -12]	# EXPONENTE
 		li			$k0, 1					# Counter
		sw			$s5, 84($a3)			# Store " x " 84($a3)
		lwc1		$f16, 84($a3)			# Load in $f1 parameter
		cvt.s.w 		$f16, $f16

		
		looping:
 			beq			$k0 $s6 exitT
 			move		$a0 $s7			# To input "expo" function
 			
 			# Orden en #f18 -> $f13
 			sw			$s7, 88($a3)		# Store " n " 84($a3)
			lwc1		$f18, 88($a3)		# Load in $f1 parameter
			cvt.s.w 		$f18, $f18
 			
 			mov.s		$f12 $f16			# Number f16 -> $f12
 			mov.s		$f13 $f18			# Order en #f18 -> $f13
 			jal			expo				# x**n
 			mov.s		$f5 	$f28			# move answer
 			
 			mov.s		$f6 $f18				# move answer to divide
 			mov.s		$f3 $f24			# empty $f3

			jal			floatDivision		# invoke floatDivision

			li			$t4 0				# add or sub it depends of $k0
			beq			$t4 $k0	 minus
			li			$t4 2
			beq			$t4 $k0	 minus
			li			$t4 4
			beq 		$t4 $k0	 minus
			li			$t4 6
			beq			$t4 $k0	 minus
			li			$t4 8
			beq			$t4 $k0	 minus
			li			$t4 10
			beq			$t4 $k0	 minus	
			li			$t4 12
			beq			$t4 $k0	 minus
			sub.s		$f31 $f31 $f30															
			
			j			exiit
			minus:			
					add.s		$f31 $f31 $f30

			exiit:
				# Cambiar de signo a positivo
				mov.s		$f12 $f31
				add.s		$f12 $f16 $f12 
				beqz		$t7 change
				abs.s		$f12 $f12				
				change:

				jal			showAnswer
				mov.s		$f12 $f24
				addi		$s7 $s7 1
				addi		$k0 $k0 1
				li			$t7 0
				j			looping

 		exitT:
 			lw			$ra, 80($a3)
 			sw			$zero 	0($sp)	
 			addi		$sp, $sp, 4	
			jr			$ra
		

				
expo:											# Parameters: $f12 $f13
		addi		$sp, $sp, -4					# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)					# Store $ra value
		
		mov.s		$f14 $f12					# aux "a"
		mov.s		$f15 $f13					# aux "b"		

		mov.s		$f1 $f12					
		loopE:
			c.eq.s	$f15 $f24					# if b == 0
			bc1t			exitE					# exit
				mov.s		$f2	$f14			# inpurt for multiplication
				jal			floatMultiplication
				sub.s		$f15 $f15 $f21
			j loopE
		exitE:
			mov.s		$f28 $f3
			mov.s		$f3 $f24
			lw 			$ra, 0($sp)				# Store $ra value
			sw			$zero 	0($sp)	
			addi		$sp, $sp, 4				# Asigns one space in the stack to store $ra value
			jr			$ra
		
floatDivision:									# Parameters on $f5 and $f6
		mov.s		$f1 $f5
  		mov.s		$f2 $f6
		addi		$sp, $sp, -4					# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)					# Store $ra value
		
  		jal			 integerDivision
		mov.s		$f30 $f19
		mov.s  		$f19 $f24
  		add.s		$f8 $f7 $f6
  		c.eq.s		$f8 $f24
  		bc1t			endProgr # a > b pero tiene decimales
  		impropercase1:
				# f19 quocient
				# f8 remainder
				# f10 = 0.10 
				# f11 = 0.01
				mov.s		$f1 $f9					# Multiplication parameter 1
				mov.s		$f2 $f8					# Multiplication parameter 2
				mov.s		$f8 $f24				# Empty $f8
				jal			floatMultiplication
					
				mov.s		$f2 $f6					# Return of multiplication
				jal			integerDivision
				add.s		$f8 $f7 $f6				# Move result to $f8
				
				mov.s		$f1 $f10					# input parameters for multiplication
				mov.s		$f2 $f19					# input parameters for multiplication
				mov.s		$f19 $f24				# Empty $f19
				jal			floatMultiplication		# obtain the unit part 0.10 * $f19
				add.s		$f30 $f30 $f1			# Add to integer part
				
				# Repeat the procces for hundreds
				
				mov.s		$f1 $f9					# input parameter 1 for multiplication
				mov.s		$f2 $f8					# input parameter 2 for multiplication
				mov.s		$f8 $f24				
				jal			floatMultiplication
				
				mov.s		$f2 $f6					# Return of multiplication
				jal			integerDivision
				
				mov.s		$f1 $f11					# input parameter 1 for multiplication
				mov.s		$f2 $f19					# input parameter 2 for multiplication
				mov.s		$f8 $f24				# Empty $f8
				jal			floatMultiplication		# obtain the hundred part 0.01 * $f19
				add.s		$f30 $f30 $f1			# Add to integer part
			
  		endProgr:
  			mov.s		$f13 $f24					# Empty Auxiliar Registers
  			mov.s		$f14 $f24
  			mov.s		$f19 $f24
  		  			  			
  			lw 			$ra, 0($sp)					# Load $ra
			sw			$zero 	0($sp)				# Empty Stack
			addi		$sp		$sp,4
  			jr			$ra
  			
factori:
		addi		$sp, $sp, -4						# Asigns one space in the stack to store $ra value
		sw 			$ra, 0($sp)						# Store $ra value
		li 			$t1, 0x10010000					# Initialize memory allocation
		sw			$a0, 0($t1)						# store in memory
		lwc1		$f1, 0($t1)						# Load in $f1 parameter
		cvt.s.w 		$f1, $f1		
		
		sub.s		$f2 $f1 $f21						# f2 = f1 - 1
		mov.s		$f17 $f2							# aux = $f17
			
		loop:
			c.eq.s		$f24 $f2					# if f2 != 0
			bc1t			exitLoopMintt				# salir
				jal			floatMultiplication
				mov.s		$f2 $f17					# return of multiplication
				sub.s		$f17 $f17 $f21			# aux (# b = b - 1)
				sub.s		$f2 $f2 $f21				# b = b - 1
			j loop									# loop

	exitLoopMintt:
		lw 			$ra, 0($sp)						# Store $ra value
		sw			$zero 	0($sp)					# empty stack
		addi		$sp, $sp,4				
		jr			$ra								# return
		
floatMultiplication:	# Parameters $f1 $f2 result in $f1
		c.eq.s	$f1, $f24						# if (f1 == 0 ) exit	Float part
		c.eq.s	$f2, $f24						# if (f2 == 0 ) exit 	Integer part
		bc1t		zeroM							# exit		
		
		mov.s		$f3 $f1 						# aux decimal part
		
		loopIntM:
			sub.s		$f2,$f2,$f21				# integer part - 1
			c.eq.s		$f2 $f24				# if integer part = 0 ??
			bc1t			exitLoopMint			# exit
			add.s		$f1, $f1, $f3				# add decimal part 
			j			loopIntM				# loop
		zeroM:								
			mov.s		$f1, $f24				# Empty $f1 = 0
		exitLoopMint:
			jr			$ra						# exit

integerDivision:
		# Input parameters $f1 y $f2	
		loopDivInt:
		sub.s		$f7 $f1 $f2				# aux $f7 = $f1 - $f2
		sub.s		$f1 $f1 $f2				# f1 = f1 - f2
		c.lt.s		$f7 $f24				# if $f7 ($f1 - $f2 )<=0  exit
		bc1t			exitLoopInt				# exit
		add.s		$f19, $f19, $f21			# aux = aux  + 1
		j			loopDivInt				# loop
		exitLoopInt:	
			jr			$ra 				# return
		
showAnswer:	
		addi			$t5 $k0 1			# Order Counter

		li	 		$v0,  4					# Send the first message
		la	 		$a0, number1
		syscall	
		
		li			$v0, 1
		move		$a0 $t5
		syscall
		
		li	 		$v0,  4					# Print a jump line
		la	 		$a0, answMsg
		syscall	
		
		li			$v0 2					# Print the answer
		syscall
		
		li	 		$v0,  4					# Print a jump line
		la	 		$a0, jumpLine
		syscall	
		jr			$ra
END:
		li 			$v0, 10
		syscall	
