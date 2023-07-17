.data
vector: .word 0 0 0 0
.text

main:
add s0, zero, zero
#Teste 2
T: 
addi a0, zero, 1
addi a1, zero, 6
la   a2, vector
jal  ra, primes
addi t0, zero, 3
beq  t0, a0, OK
beq  zero,zero, END
OK:  addi s0, s0, 1 #Test passed
beq  zero,zero, END

##############################################################
#x31 = number of prime numbers found
#x30 = temporary
#x29 = i loop variable
#x28 = j loop variable
#x7 =  j*j temporary variable
#x6 = prime number flag
primes:                      #This initial code eliminates any number below 3
add  x31, x0,  x0            #set the prime number counter to 0
addi x30, x0,  3             #set temporary variable for branch
add  x29, a0,  x0
bge  a0,  x30, skip          #if(a0 >= 3) jump
addi x30, x0,  2		     #change x30 to 2 and store it on the vector
sw   x30, 0(a2)              #This way, all numbers below 3 are removed, since there cant be prime numbers, decreasing the loop.
addi a2,  a2,  4             #update vector position
addi x31, x31, 1             #increase total number of primes found variable
addi x29, x0,  3

skip:
addi x30, x0,  2
rem  x30, a0,  x30
bne  x30, x0,  loop_1        #(if a0 % x30 == 0) a0++
addi x29, x29, 1             #updates the initial number if it is divisible by 2
                             #This way, the initial number will always be a odd number.

loop_1:                      #for(i = a0; i <= a1; i+2)
bgt  x29, a1,  exit          #ends if i > a1
add  x6,  x0,  x0            #flag = 0
addi x28, x0,  2             #set j 
loop_2:                      #for(j = 2; j*j <= i; j++)
mul  x7,  x28, x28           #set j*j
bgt  x7,  x29, end_loop2     # j*j > i break loop
rem  x30, x29, x28		     #i % j
beq  x30, x0,  flag_1        #if(i % j == 0) flag = 1 v
addi x28, x28, 1             #j++
j loop_2

end_loop2:                  
beq  x6,  zero, flag_0       #if flag == 0, i = prime
 
flag_1:			             #if this code executes, i can be divided by j, so loop_2 can be finalized earlier
addi x6,  x0,  1             #flag = 1
addi x29, x29, 2             # i + 2
j loop_1

flag_0:
sw   x29, 0(a2)             
addi a2,  a2,  4             #updates vector
addi x31, x31, 1             #primes number counter +1
addi x29, x29, 2             # i + 2
j loop_1

exit:
addi a0,  x31, 0             #insert the number of prime numbers found in a0
jalr zero, 0(ra)


END: add zero, zero, zero
