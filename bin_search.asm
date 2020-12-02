.data
	array:		.space 40
	number:		.space 4
	input_array:	.asciiz "Input array (one element at a time):\n"
	input_search:	.asciiz "Input the search value:\n"
	output:		.asciiz "Located at spot "

.text
	main:
	# Register Assignments:
	# $s0 = A
	# $s1 = val
	# $s2 = low
	# $s3 = high
	# $t0 = count down from 10

		# initialize vars
		la     $s0, array       # set A
		mov    $s2, $s0         # low = A
		move   $s3, $s0			# high = A

		li	$t0, 10				# temp = 10

		# get array message
		la	$a0, input_array
		li	$v0, 4				# sys call code for print_str
		syscall					# print it

		# read in array
		read_numbers:
			li	$v0, 5			# sys call code for read_int
			la	$a0, number
			li	$a1, 4
			syscall				# read it
			sw	$v0, ($s3)		# store into the array
			addi	$s3, $s3, 4		# add 4 to $s3
			addi	$t0, $t0, -1		# $t0 = $t0 - 1
			bgtz	$t0, read_numbers	# if $t0 > 0 then read_numbers

		subi	$s3, $s3, 4			# $s3 = $s3 - 4

		# get query message
		la	$a0, input_search
		li	$v0, 4				# sys call code for print_str
		syscall					# print it

		# get query
		addi	$v0, $zero, 5			# sys call code for read_int
		la	$a0, number
		li	$a1, 1
		syscall					# print it
		move	$s1, $v0			# Put the search into $s1

		# print output string
		la	$a0, output
		li	$v0, 4				# sys call code for print_str
		syscall

		# set arguments and call search
		move	$a0, $s0			# $a0 = $s0
		move	$a1, $s1			# $a1 = $s1
		move	$a2, $s2			# $a2 = $s2
		move	$a3, $s3			# $a3 = $s3
		jal	search				# jump to search and save position to $ra

		# print answer
		move	$a0, $v0
		li	$v0, 1				# sys call code for print_int
		syscall

		addi	$v0, $zero, 10
		syscall


	search:						# binary search
	# Register Assignments:
	# $a0 = A
	# $a1 = val
	# $a2 = low
	# $a3 = high
	# $s0 = mid address
	# $s1 = mid value
	# $s2 = low
	# $s3 = high

		# store stack frame
		subu	$sp, $sp, 20			# make room for return address and paramaters
		sw	$ra, ($sp)			# store return address
		sw	$s0, 4($sp)			#
		sw	$s1, 8($sp)			#
		sw	$s2, 12($sp)			#
		sw	$s3, 16($sp)			#

		# set low/high
		move	$s2, $a2			# $s2 = $a2
		move	$s3, $a3			# $s3 = $a3

		# high < low?
		li	$v0, -1				# $v0 = -1
		blt	$s3, $s2, return		# if $s3 < $s2 then return

		# set mid
		add	$s0, $s2, $s3			# $s0 = $s2 + $s3
		srl	$s0, $s0, 3			# floor divide by 8
		sll	$s0, $s0, 2
		lw	$s1, ($s0)			# get value of mid

		# greater?
		bgt	$s1, $a1, greater_than		# if $s1 > $a1 then search

		# less?
		blt	$s1, $a1, less_than		# if $s1 < $a1 then search

		# Found!
		sub	$v0, $s0, $a0			# $v0 = $s0 - $a0
		srl	$v0, $v0, 2			# divide by 4
		jr	$ra				# jump to $ra

		greater_than:
			addi	$a3, $s0, -4		# $a3 = $s1 - 1
			jal	search			# jump to search
			j	return			# jump to return

		less_than:
			addi	$a2, $s0, 4		# $a2 = $s1 + 1
			jal	search			# jump to search
			j	return			# jump to return

		return:
			# return stack frame
			lw	$ra, ($sp)		#
			lw	$s0, 4($sp)		#
			lw	$s1, 8($sp)		#
			lw	$s2, 12($sp)		#
			lw	$s3, 16($sp)		#
			addu	$sp, $sp, 20		# restore stack pointer

			jr	$ra			# jump back
