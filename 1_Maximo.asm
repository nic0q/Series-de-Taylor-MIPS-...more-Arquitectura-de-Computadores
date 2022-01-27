# $vx => retornos subrutinas, códigos syscall
# $ax => argumentos subrutinas/syscall
# $tx => variables locales
# $sx => variables globales

.data
	number1: .asciiz "Por favor ingrese el primer entero:  "
	number2: .asciiz "Por favor ingrese el segundo entero:  "
	answer: .asciiz "El maximo es: "
.text
main:
		li	 		$v0,  4				# Send the first message
		la	 		$a0, number1
		syscall
		li	 		$v0, 5				# Gets number1
		syscall
		move 		$s0, $v0 			# Store in $s0
 		#---------------------------------
		li			$v0,  4				# Send the second message
		la			$a0, number2
		syscall
		li 			$v0, 5				# Gets number2
		syscall
		move 		$s1, $v0			# Store in $s1
 		#---------------------------------
		jal			greater
		jal 			EXIT

greater:
		slt 	  		$s2, $s0, $s1		 # Compare both numbers
		bnez 		$s2, greaterS1		 # If $s1 is greater than $s0 jumps to greaterS1
		move 		$t1, $s0 		 	 # Si no el mayor es $s0
		j    			 printAnswer

greaterS1:
		move 		$t1, $s1				# Auxiliar register $t1
		j 			printAnswer

printAnswer:
		li	 		$v0, 4
		la	 		$a0,  answer
		syscall							# Send the message
		li	   		$v0, 1
		move 		$a0, $t1				# Send the greater
		syscall
		li			$s0, 0				# Store 0 at all the used registers
		li			$s1, 0
		li			$s2, 0
		jr 			$ra					# return to main

EXIT:
		li	 		$t0, 0   				# Empty local variables
		li	 		$t1, 0 	
		li	 		$v0, 10
		syscall
