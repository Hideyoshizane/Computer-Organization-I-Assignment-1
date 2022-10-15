.data 
vetor:.word 3 6 7 8 5 7 4 3 1 9 2
##### START MODIFIQUE AQUI START #####
vecPJ: .word 6 5 4 3 2 9 8 7 6 5 4 3 2
vecCPF: .word 11 10 9 8 7 6 5 4 3 2 
##### END MODIFIQUE AQUI END ##### 
.text 

main: 
    la   x12, vetor 
    addi x13, x0, 11
    addi x14, x0, 0 
    jal  x1, verificadastro 
    beq  x0,x0,FIM

##### START MODIFIQUE AQUI START #####
verificadastro:
    addi x10, x0, -1 	 	    #Recebe resultado final se é válido ou não o CPF/CNPJ 
    addi x17, x0, 0 			#Insere se é CPF ou CNJP

    bne x17, x0 cnpj		 	#Pular para cnpj caso x17 != 0
    jal x1, verificacpf
    beq x0,x0,FIM

cnpj:
    jal x1, verificacnpj
    beq x0,x0,FIM 

######################################################
verificacpf:
#Parte do CPF
#x12 = Vetor principal
#x7  = Vetor CPF
#x6  = Valor temporário
#x28 = Condicional de looping
#x29 = Condicional de looping
#x30 = Valor temporário
#x31 = Valor temporário
#x5  = Endereço de retorno das subfunções
#x1  = Endereço de retorno verificacadastro
######################################################
###### Parte que chama as sub funções  ###############
    la   x7, vecCPF
    #Prepara para o looping de multiplicação.
    addi sp, sp, -36 
    addi x7, x7,  4     	    #Pula para vecCPF[1] para o valor inicial ser 10 e não 11.
    addi x28, x0, 9     	    #variavel de condição final do loop.
    jal  x5, LoopMultiplica

    #Prepara para o looping de soma
    addi sp, sp, -44 		    #Reseta a pilha
    add  x28, x0, x0  		    #Reseta o registrador de looping
    add  x31, x0, x0
    addi x29, x0, 9  		    #Variável de final de loop
    addi x12, x12, -8 		    #Correção no valor do vetor
    jal  x5, SomaPilha
    jal  x5, Multiplicacao

    #Prepara para o looping de multiplicação do segundo dígito
    addi sp, sp, -36 	        #Reseta pilha
    addi x12, x12, -36  	    #Reseta vetor com dados
    addi x7, x7, -48    	    #Reseta vetor de multiplicação, agora pro 1 valor
    addi x28, x0,  10    	    #Variavel de condição final do loop
    jal  x5, LoopMultiplica
    #Prepara para o looping de soma
    addi sp, sp, -48    	    #Reseta a pilha
    add  x28, x0, x0 		    #Reseta o registrador de looping
    add  x31, x0, x0
    addi x29, x0, 10  		    #Variável de final de loop
    addi x12, x12, -8 		    #Correção no valor do vetor
    jal  x5, SomaPilha
    jal  x5, Multiplicacao
    jal  x0, Valido      	    #Caso chegue aqui, todos os passos indicam que é válido o CPF
    
######################################################
### Sub funções do CPF, algumas são usadas no CNPJ ###

    LoopMultiplica:			    #Multiplica os vetores e guarda na pilha
        lw   x30, 0(x12)        #Pega o digito
        lw   x6, 0(x7)     	    #Pega o multiplicador do segundo vetor
        mul  x30, x30, x6  
        sw   x30, 0(sp)    	    #Guarda na pilha
        addi x7, x7, 4   	    #Aumenta no vetor auxiliar
        addi x12, x12, 4 	    #Aumenta no vetor
        addi sp, sp, 4   	    #Aumenta na pilha
        bge  x28, x0 , LoopMultiplicaPJ
        jalr x0, 0(x5)

    SomaPilha:           	    #Soma o total da pilha pra ser usado em seguida
        lw   x30, 0(sp)         #Busca valor na pilha
        add  x31, x31, x30 	    #Adiciona o somatório no final
        addi sp, sp, 4   	    #Aumenta a pilha
        addi x28, x28, 1
        blt  x28, x29, SomaPilha
        jalr x0, 0(x5)

    Multiplicacao:              #Multiplica e acha resto para validar o dígito
        addi x30, x0, 10
        mul  x31, x31, x30 	    #Soma * 10 
        addi x30, x0, 11
        rem  x31, x31, x30 	    #Soma % 11
        addi x30, x0, 10
        bne  x31, x30, Resto    #Pula linha de transformação caso resto != 10
        add  x31, x0, x0        #Transforma em 0 caso resto == 10
        Resto:
        lw   x30, 0(x12)
        bne  x31, x30, Invalido #Caso resto != digito levar ao processo final que finaliza a função
        jalr x0, 0(x5)

    Valido:
        addi x10, x0, 1
        jalr x0, 0(x1)

    Invalido:
        addi x10, x0, 0
        jalr x0, 0(x1)

######################################################
verificacnpj:
#Parte do CNPJ
#x12 = vetor principal
#x7  = vetor CNPJ
#x6  = valor temporário
#x28 = condicional de looping
#x29 = condicional de looping
#x30 = valores temporários
#x31 = valores temporários
#x5  = endereço de retorno das subfunções
#x1  = endereço de retorno verificacadastro
###################################################### 
    la x7, vecPJ
    #Prepara para o looping de multiplicação.
    addi sp, sp, -48
    addi x7, x7, 4 				#Pula pra a[1] no vetor de multiplicação
    addi x28, x0, 11 			#Variavel de condição final do loop
    jal  x5, LoopMultiplicaPJ
    
    #Prepara para o looping de soma
    addi sp, sp, -48
    add  x28, x0, x0  			#Reseta o registrador de looping
    add  x31, x0, x0
    addi x29, x0, 12  			#Variável de final de loop
    jal  x5, SomaPilha   		#Mesma função utilizado no CPF
    jal  x5, MultiplicacaoPJ
    #Prepara para o looping de multiplicação do segundo dígito
    addi sp, sp, -48
    addi x12, x12, -48 			#Reseta vetor com dados
    addi x7, x7, -52    		#Reseta vetor de multiplicação, agora pro 1 valor
    addi x28, x0,  13    		#Variavel de condição final do loop
  	jal  x5, LoopMultiplicaPJ
	#Prepara para o looping de soma do segundo dígito
    addi sp, sp, -56
    add  x28, x0, x0  			#Reseta o registrador de looping
    add  x31, x0, x0
    addi x29, x0, 13  			#Variável de final de loop
    jal  x5, SomaPilha   		#Mesma função utilizado no CPF
    addi x12, x12, -4
    jal  x5, MultiplicacaoPJ
    jal  x0, Valido      		#Caso chegue aqui, todos os passos indicam que é válido o CNPJ #Mesmo do CPF


######################################################
############### Sub funções do CNPJ  #################
    LoopMultiplicaPJ:
        lw   x30, 0(x12)  		#Pega o valor
        lw   x6, 0(x7) 			#Pega o multiplicador
        mul  x30, x30, x6
        sw   x30, 0(sp)
        addi x12, x12, 4 		#Aumenta no vetor
        addi x7, x7, 4 			#Aumenta no vetor multiplicador
        addi sp, sp, 4  		#Aumenta na pilha
        addi x28, x28, -1
        bge  x28, x0 , LoopMultiplicaPJ
    	jalr x0, 0(x5)
        
        
     MultiplicacaoPJ:            #Multiplica e acha resto para validar o dígito
        addi x30, x0, 11
        rem  x31, x31, x30 	     #Soma % 11
        addi x30, x0, 2
        bge  x31, x30 , RestoPJ
        add  x31, x0, x0       	 #Trasforma em 0 caso resto < 2
        jal  x0, PJTeste       	 #Pula a subtração caso o dígito seja 0
        RestoPJ:
        addi x30, x0, 11
        sub  x31, x30, x31	     # 11 - Resto
        lw   x30, 0(x12)		 #Recebe dígito verificador
        PJTeste:
        bne  x31, x30, Invalido  #Caso resto != digito levar ao processo final que finaliza a função #Mesmo inválido do CPF
        jalr x0, 0(x5)
    

##### END MODIFIQUE AQUI END ##### 
FIM: add x1, x0, x10
