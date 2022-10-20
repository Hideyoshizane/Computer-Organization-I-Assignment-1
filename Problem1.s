.data
vetor: .word 1 2 3 4 5 6 7
.text
main:

la   x12, vetor         #Receive vector
addi x13, x0,   7       
addi x13, x13, -1
slli x13, x13,  2
add  x13, x13,  x12     #Receive the end of the vector
jal  x1,  reverse
beq  x0,  x0,   END

reverse:
    beq  x12, x13, Final #If the start address > end address, end 

    #Load values into register
    lw   x6,  0(x12) 
    lw   x7,  0(x13)

    #Store values in reverse
    sw   x6,  0(x13)
    sw   x7,  0(x12)

    #Increment the address
    addi x12, x12,  4
    addi x13, x13, -4

    jal  x0,  inverte
    Final:
    addi x10, x0,   1 #Add 1 to signal that success of operation
    jalr x0,  0(x1)
FIM: 
    add x1, x0, x10
