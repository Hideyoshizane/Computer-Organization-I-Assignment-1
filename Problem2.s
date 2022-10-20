.data 
vector:  .word 6  2  3 8 4 2 3 8 0 0 0 1 1 5 #Insert here the CPF or CNPJ
vecPJ:  .word 6  5  4 3 2 9 8 7 6 5 4 3 2
vecCPF: .word 11 10 9 8 7 6 5 4 3 2 
.text 

main: 
    la   x12, vector 
    jal  x1,  verifyregistration 
    beq  x0,  x0, END

verifyregistration:
    addi x10, x0, -1 	 	    #Register that get result, 1 is valid, 0 is invalid
    addi x17, x0,  1 			#0 for CPF, 1 for CNPJ

    bne  x17, x0, cnpj		 	#Jump to cnpj if value == 1
    jal  x1,  verifyCPF
    beq  x0,  x0, END

cnpj:
    jal  x1,  verifyCNPJ
    beq  x0,  x0, END 

verifyCPF:

######################################################
#x12 = Main vector tha contains the digits
#x7  = Vector that have the multiplys
#x6  = Temporary value that got the multiplier
#x28 = Looping conditional
#x29 = Looping conditional
#x30 = Temporary value for multiplication
#x31 = Temporary value for result
#x5  = Return address from sub functions
#x1  = Return address from verifyregistration
######################################################

################### Sub functions  ###################
    la   x7, vecCPF
    #Preparation for multiplication loop.
    addi sp,  sp, -36 			#rReset stack 
    addi x7,  x7,   4     	    #Jump to vecCPF[1], first multiplication stage must start at 10, not 11.
    addi x28, x0,   9     	    #End loop condition
    jal  x5,  MultiplicationLoop

    #Preparation to sum loop.
    addi sp,  sp, -40 		    #Reset stack 
    add  x28, x0,  x0  		    #Reset looping registrator
    add  x31, x0,  x0
    addi x29, x0,   9  		    #End loop condition
    addi x12, x12, -4 		    #Main vector position correction
    jal  x5,  SumStack
    jal  x5,  DigitVerificationCPF

    #Preparation for multiplication loop for the second digit.
    addi sp,  sp,  -36 	        #Reset stack
    addi x12, x12, -36  	    #Reset main vector
    addi x7,  x7,  -44    	    #Reset multiplication vector, now to vecCPF[0]
    addi x28, x0,   10    	    #End loop codition
    jal  x5,  MultiplicationLoop

    #PPreparation to sum loop.
    addi sp,  sp,  -44    	    #Reset stack
    add  x28, x0,   x0 		    #Reset looping registrator
    add  x31, x0,   x0
    addi x29, x0,   10  		#End loop condition
    addi x12, x12,  -4 		    #Main vector position correction
    jal  x5, SumStack
    jal  x5, DigitVerificationCPF
    jal  x0, Valid      	    #If this function is called, both digits is valid, this way, CPF is valid
    
######################################################
########### CPF exclusive sub function ###############

	DigitVerificationCPF:       #Multiply and mod to find verification digit
        addi x30, x0,   10
        mul  x31, x31,  x30	    #Sum * 10 
        addi x30, x0,   11
        rem  x31, x31,  x30	    #Sum % 11
        addi x30, x0,   10
        bne  x31, x30,  Result  #Jump conversion line if result != 10 
        add  x31, x0,   x0      #Transform into 0 if result == 10
        Result:
        lw   x30, 0(x12)
        bne  x31, x30,  Invalid #If result != verification digit call ending function
        jalr x0,  0(x5)

######################################################
################## Sub functions #####################

    MultiplicationLoop:			#Multiply vectors and store on stack
        lw   x30, 0(x12)        #Get digit
        lw   x6,  0(x7)     	#Get mutiplication number
        mul  x30, x30,  x6  
        sw   x30, 0(sp)    	    #Store on stack
        addi x7,  x7,   4   	#Add on multiplication vector 
        addi x12, x12,  4 	    #Add on main vector
        addi sp,  sp,   4  	    #Add on stack
        addi x28, x28, -1
        bge  x28, x0 ,  MultiplicationLoop
        jalr x0,  0(x5)

    SumStack:           	    #Sum whole stack to be used later
        lw   x30, 0(sp)         #Load from stack
        add  x31, x31,  x30	    #Sum to register
        addi sp,  sp,   4  	    #Add on stack
        addi x28, x28,  1
        blt  x28, x29,  SumStack
        jalr x0,  0(x5)

    Valid:
        addi x10, x0, 1
        jalr x0,  0(x1)

    Invalid:
        addi x10, x0, 0
        jalr x0,  0(x1)

######################################################
verifyCNPJ:
    la x7, vecPJ
    #Preparation for multiplication loop.
    addi sp,  sp, -48
    addi x7,  x7,  4			#Jump to vecPJ[1], first multiplication stage must start at 5, not 6.
    addi x28, x0,  11 			#End loop codition
    jal  x5,  MultiplicationLoop
    
    #Preparation to sum loop.
    addi sp,  sp, -48
    add  x28, x0,  x0           #Reset looping registrator
    add  x31, x0,  x0
    addi x29, x0,  12  			#End loop condition
    jal  x5,  SumStack   		
    jal  x5,  DigitVerificationCNPJ

    #Preparation for multiplication loop for the second digit.
    addi sp,  sp,  -48
    addi x12, x12, -48 			#Reset main vector
    addi x7,  x7,  -52    		#Reset multiplication vector, now to vecPJ[0]
    addi x28, x0,   13    		#Variavel de condição final do loop
  	jal  x5,  MultiplicationLoop

	#PPreparation to sum loop.
    addi sp,  sp,  -56
    add  x28, x0,   x0 			#Reset looping registrator
    add  x31, x0,   x0
    addi x29, x0,   13 			#End loop codition
    addi x12, x12, -4			#Correção no valor do vetor
    jal  x5,  SumStack   		#Mesma função utilizado no CPF
    jal  x5,  DigitVerificationCNPJ
    jal  x0,  Valid      		#If this function is called, both digits is valid, this way, CNPJ is valid


######################################################
########## CNPJ exclusive sub function ###############
       
     DigitVerificationCNPJ:      #Mod to find verification digit
        addi x30, x0,  11
        rem  x31, x31, x30 	     #Sum % 11
        addi x30, x0,  2
        bge  x31, x30, RestoPJ
        add  x31, x0,  x0      	 #Trasform into 0 if result < 2
        jal  x0,  PJTeste      	 #Jump subtraction if result == 0
        RestoPJ:
        addi x30, x0,  11
        sub  x31, x30, x31	     # 11 - Result
        PJTeste:
        lw   x30, 0(x12)		 #Get verification digit
        bne  x31, x30, Invalid   #CIf result != verification digit call ending function
        jalr x0,  0(x5)
    
END: 
        add x1, x0, x10
