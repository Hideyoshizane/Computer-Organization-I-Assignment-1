.data 
vetor:.word 1 1 4 4 4 7 7 7 0 0 0 1 6 1
##### START MODIFIQUE AQUI START #####
vecPJ: .word 6 5 4 3 2 9 8 7 6 5 4 3 2
vecCPF: .word 11 10 9 8 7 6 5 4 3 2 
##### END MODIFIQUE AQUI END ##### 
.text 

main: 
    la x12, vetor 
    addi x13, x0, 11
    addi x14, x0, 0 
    jal x1, verificadastro 
    beq x0,x0,FIM

##### START MODIFIQUE AQUI START #####
verificadastro:
    addi x6, x0, -1 	 	  #recebe resultado final se é válido ou não o CPF/CNPJ 
    addi x3, x0, 1 			  #insere se é CPF ou CNJP

    bne x3, x0 cnpj		 	  #Pular para cnpj caso x3 != 0
    jal x1, verificacpf
    beq x0,x0,FIM

cnpj:
    jal x1, verificacnpj
    beq x0,x0,FIM 

######################################################
verificacpf:
#Parte do CPF
#x12 = vetor principal
#x9  = vetor CPF
#x11 = condicional de looping
#x14 = condicional de looping
#x8  = valores temporários
#x13 = valores temporários
#x5  = endereço de retorno das subfunções
#x1  = endereço de retorno verificacadastro
######################################################
###### Parte que chama as sub funções  ###############
    la x9, vecCPF
    #Prepara para o looping de multiplicação.
    addi sp, sp, -36 
    addi x9, x9,  4     	  #Pula para vecCPF[1] para o valor inicial ser 10 e não 11.
    addi x11, x0, 9     	  #variavel de condição final do loop.
    jal x5, LoopMultiplica

    #Prepara para o looping de soma
    addi sp, sp, -44 		  #reseta a pilha
    add x11, x0, x0  		  #reseta o registrador de looping
    add x13, x0, x0
    addi x14, x0, 9  		  #variável de final de loop
    addi x12, x12, -8 		  #Correção no valor do vetor
    jal x5, SomaPilha
    jal x5, Multiplicacao

    #Prepara para o looping de multiplicação do segundo dígito
    addi sp, sp, -36 	      #reseta pilha
    addi x12, x12, -36  	  #reseta vetor com dados
    addi x9, x9, -48    	  #reseta vetor de multiplicação, agora pro 1 valor
    addi x11, x0,  10    	  #variavel de condição final do loop
    jal x5, LoopMultiplica
    #Prepara para o looping de soma
    addi sp, sp, -48    	  #reseta a pilha
    add x11, x0, x0 		  #reseta o registrador de looping
    add x13, x0, x0
    addi x14, x0, 10  		  #variável de final de loop
    addi x12, x12, -8 		  #Correção no valor do vetor
    jal x5, SomaPilha
    jal x5, Multiplicacao
    jal x0, Valido      	  #Caso chegue aqui, todos os passos indicam que é válido o CPF
    
######################################################
### Sub funções do CPF, algumas são usadas no CNPJ ###

    LoopMultiplica:			  #Multiplica os vetores e guarda na pilha
        lw  x8, 0(x12)    	  #pega o digito
        lw x10, 0(x9)     	  #pega o multiplicador do segundo vetor
        mul x8, x8, x10  
        sw  x8, 0(sp)    	  #guarda na pilha
        addi x9, x9, 4   	  #aumenta no vetor auxiliar
        addi x12, x12, 4 	  #aumenta no vetor
        addi sp, sp, 4   	  #aumenta na pilha
        bge x11, x0 , LoopMultiplicaPJ
        jalr x0, 0(x5)

    SomaPilha:           	  #Soma o total da pilha pra ser usado em seguida
        lw x8, 0(sp)     	  #busca valor na pilha
        add x13, x13, x8 	  #adiciona o somatório no final
        addi sp, sp, 4   	  #aumenta a pilha
        addi, x11, x11, 1
        blt x11, x14, SomaPilha
        jalr x0, 0(x5)

    Multiplicacao:            #Multiplica e acha resto para validar o dígito
        addi x8, x0, 10
        mul x13, x13, x8 	  #Soma * 10 
        addi x8, x0, 11
        rem x13, x13, x8 	  #Soma % 11
        addi x8, x0, 10
        bne x13, x8, Resto    #pula linha de transformação caso resto != 10
        add x13, x0, x0       #transforma em 0 caso resto == 10
        Resto:
        lw x8, 0(x12)
        bne x13, x8, Invalido #Caso resto != digito levar ao processo final que finaliza a função
        jalr x0, 0(x5)

    Valido:
        addi x6, x0, 1
        jalr x0, 0(x1)

    Invalido:
        addi x6, x0, 0
        jalr x0, 0(x1)

######################################################
verificacnpj:
#Parte do CNPJ
#x12 = vetor principal
#x9  = vetor CPF
#x11 = condicional de looping
#x14 = condicional de looping
#x8  = valores temporários
#x13 = valores temporários
#x5  = endereço de retorno das subfunções
#x1  = endereço de retorno verificacadastro
###################################################### 
    la x9, vecPJ
    #Prepara para o looping de multiplicação.
    addi sp, sp, -48
    addi x9, x9, 4 				#pula pra a[1] no vetor de multiplicação
    addi x11, x0, 11 			#variavel de condição final do loop
    jal x5, LoopMultiplicaPJ
    
    #Prepara para o looping de soma
    addi sp, sp, -48
    add x11, x0, x0  			#reseta o registrador de looping
    add x13, x0, x0
    addi x14, x0, 12  			#variável de final de loop
    jal x5, SomaPilha   		#Mesma função utilizado no CPF
    jal x5, MultiplicacaoPJ
    #Prepara para o looping de multiplicação do segundo dígito
    addi sp, sp, -48
    addi x12, x12, -48 			#reseta vetor com dados
    addi x9, x9, -52    		#reseta vetor de multiplicação, agora pro 1 valor
    addi x11, x0,  13    		#variavel de condição final do loop
  	jal x5, LoopMultiplicaPJ
	#Prepara para o looping de soma do segundo dígito
    addi sp, sp, -56
    add x11, x0, x0  			#reseta o registrador de looping
    add x13, x0, x0
    addi x14, x0, 13  			#variável de final de loop
    jal x5, SomaPilha   		#Mesma função utilizado no CPF
    addi x12, x12, -4
    jal x5, MultiplicacaoPJ
    jal x0, Valido      		#Caso chegue aqui, todos os passos indicam que é válido o CNPJ #Mesmo do CPF


######################################################
############### Sub funções do CNPJ  #################
    LoopMultiplicaPJ:
        lw  x8, 0(x12)  		#pega o valor
        lw  x10, 0(x9) 			#pega o multiplicador
        mul x8, x8, x10
        sw  x8, 0(sp)
        addi x12, x12, 4 		#aumenta no vetor
        addi x9, x9, 4 			#aumenta no vetor multiplicador
        addi sp, sp, 4  		#aumenta na pilha
        addi x11, x11, -1
        bge x11, x0 , LoopMultiplicaPJ
    	jalr x0, 0(x5)
        
        
     MultiplicacaoPJ:            #Multiplica e acha resto para validar o dígito
        addi x8, x0, 11
        rem x13, x13, x8 	     #Soma % 11
        addi x8, x0, 2
        bge x13, x8 , RestoPJ
        add x13, x0, x0       	 #trasforma em 0 caso resto < 2
        jal x0, PJTeste       	 #pula a subtração caso o dígito seja 0
        RestoPJ:
        addi x8, x0, 11
        sub  x13, x8, x13	     # 11 - Resto
        lw x8, 0(x12)			 #Recebe dígito verificador
        PJTeste:
        bne x13, x8, Invalido 	 #Caso resto != digito levar ao processo final que finaliza a função #Mesmo inválido do CPF
        jalr x0, 0(x5)
    

##### END MODIFIQUE AQUI END ##### 
FIM: add x1, x0, x10
