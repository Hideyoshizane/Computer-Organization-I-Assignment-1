.data
cardnumber: .word 4 9 1 6 6 4 1 8 5 9 3 6 9 0 8 0
luhn:       .word 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2  
.text
main:
la   a0, cardnumber
jal  ra, verify
beq  zero,zero,END
##### START MODIFIQUE AQUI START #####
#x31 = get vector value
#x30 = loop counter
#x29 = comparison variable
#x6  = comparsion variable 2
verify:
li   x30,  16
li   x29,   9

loop_1:                  #check if the credit card numbers are  0 <= x <= 9, else, it is invalid
beqz x30, part2          #while X30(16) != 0 loop
lw   x31, 0(a0)
bgt  x31, x29,  invalid  #if(x31 > 9)
blt  x31, x0,   invalid  #if(x31 < 0)
addi a0,  a0,   4        #jump to next card number
addi x30, x30, -1        #x30--;
j loop_1

part2:
addi a0, a0, -64         #resets credit card vector position
addi sp, sp, -4          #updates the stack
sw   ra, 0(sp)           #store the return address on the stack
jal  ra, multiplyvectors

addi x6,  x0, 10         #x6 still has the value 10 from the last function, but set it again just to make sure
remu x29, a1, x6         # a1 % 10 = y
sub  x29,  x6, x29       # 10 - y
bne  x29,  x6 reset_10   #if(x29 != 10) jump the next line
add  x29,  x0, x0        #if x29 == 10, set value to 0

reset_10:

lw   x31,  60(a0)        #get credit card last number
beq  x31, x29 valid      #if(x31 == x29) valid, else invalif
invalid:
li   a1, 0
j exit

valid:
li   a1, 1

exit:
lw   ra,   0(sp)         #insert address back to variable
addi sp,   sp, 4         #reset stack to 0
jalr zero, 0(ra)         #credit card vector already are on the first digit, not needing to reset


multiplyvectors:
####################################################
#x31 = get vector value
#x30 = loop counter
#x29 = multiplifcation result
#x28 = luhn vector
#x7  = get luhn vector value
#x6  = comparison variable
#x5  = multiplifcation quotient result
#a1  = return
#Na pilha:
# -4(sp) verify function return address
# -64(sp) pra -8(sp) multiplication vector results
####################################################
li   x30,  15
li   a1,   0
la   x28,  luhn
addi x6,   x0, 10
addi sp,   sp, -60       #Update the stack to receive the sum of vectors

loop_vector:             #loop to sum the first 15 numbers of the credit card 
beqz x30, sum
lw   x31, 0(a0)          #credit card number
lw   x7,  0(x28)         #multiplication vector number
mul  x29, x7,  x31
blt  x29, x6,  next_step #if(x29 < 10) jumps to next_step
divu x5,  x29, x6        #x29 / 10 to find the second digit
remu x29, x29, x6        #x29 % 10 to find the first digit
add  x29, x29, x5        #x29 first digit + x29 second digit

next_step:
sw   x29, 0(sp)          #store on stack
addi sp,  sp,   4        #update stack
addi a0,  a0,   4        #next credit card number
addi x28, x28,  4        #next number on the multiplication vector
addi x30, x30, -1
j loop_vector

sum:                     #sum the stack values in one variable
addi sp,  sp,  -60       #reset stack to the first value
li   x30, 15             #reset loop counter

sum_loop:
beqz x30, finalizemul    #while(x30 != 0)
lw   x29, 0(sp)          #x29 are reused to store stack values 
add  a1,  a1,   x29      #add values
addi sp,  sp,   4
addi x30, x30, -1
j sum_loop

finalizemul:
addi a0,   a0, -60       #reset vector card position
jalr zero, 0(ra)


END: add zero, zero, zero