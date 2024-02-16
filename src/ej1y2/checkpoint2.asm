section .rodata
ochos: times 8 dw 8
mask: times 4 dd -1

section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)
;array*[rdi], n[rsi]

checksum_asm:
	push rbp
	mov rbp, rsp

	.ciclo:
        cmp rsi, 0
        je .fin


		movdqu xmm0, [rdi] ;cargamos Ai
		add rdi, 16
		movdqu xmm1, [rdi] ;cargamos Bi

		paddw xmm0, xmm1 ;hacemos A + B
        movdqu xmm1, xmm0       ;guardamos A + B
        movdqu xmm2, [ochos]    ;cargamos los ochos para multiplicar cada A + B

		pmullw xmm0, xmm2       ;multiplicamos y nos quedamos con la parte alta
        pmulhw xmm1, xmm2       ;multiplicamos y nos quedamos con la parte baja

        ;armamos los enteros de 32
        movdqu xmm2, xmm0
        punpcklwd xmm0, xmm1
        punpckhwd xmm2, xmm1

        ;comparamos
        add rdi, 16
        movdqu xmm3, [rdi] ;cargamos los primeros 4 C
        add rdi, 16
        movdqu xmm4, [rdi] ;cargamos los 4 C restantes

        pcmpeqd xmm0, xmm3
        pcmpeqd xmm2, xmm4

        pand xmm0, xmm2

        movdqu xmm1, [mask]

        ptest xmm0, xmm1
        jc .todosIguales
        jmp .hayDistinto


        .todosIguales:
            mov rax, 1
            dec rsi
            add rdi, 16
            jmp .ciclo

        .hayDistinto:
            mov rax, 0
            jmp .fin

        ;xmm0 = [0][1][2][3]
        ;xmm2 = [4][5][6][7]

        ;1ra horizontal
        ;xmm0 = [0 + 1][2 + 3][4 + 5][6 + 7]

        ;2da horizontal
        ;xmm0 = [0 + 1 + 2 + 3][4 + 5 + 6 + 7][0 + 1 + 2 + 3][4 + 5 + 6 + 7]

        ;3ra horizontal
        ;xmm0 = [0 + 1 + 2 + 3 + 4 + 5 + 6 + 7][0 + 1 + 2 + 3 + 4 + 5 + 6 + 7][0 + 1 + 2 + 3 + 4 + 5 + 6 + 7][0 + 1 + 2 + 3 + 4 + 5 + 6 + 7]

        ;phaddd xmm0, xmm2
        ;phaddd xmm0, xmm0
        ;phaddd xmm0, xmm0


    .fin:
	pop rbp
	ret
