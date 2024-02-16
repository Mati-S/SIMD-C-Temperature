global temperature_asm

%define NULL 0
section .rodata
    align 16
    mascara_A dw 0xFFFF, 0xFFFF, 0xFFFF, 0x0000, 0xFFFF, 0xFFFF, 0xFFFF, 0x0000
    mascara_A2 	db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    mascara_div_3: times 4 dd 3
    mascara_255 db 0xFF        

section .text

;void temperature_asm(unsigned char *src, [rdi] 8
;              unsigned char *dst,  [rsi] 8
;              int width, [rdx] 8
;              int height, [rcx]8
;              int src_row_size, [r8] 8
;              int dst_row_size); [r9] 8


; [rdi] = *src [rsi] = *dst [rdx] = w [rcx] = h [r8] = row [r9] = col
temperature_asm:
    push rbp
    mov rbp,rsp

    push rbx
    push r12


    imul rcx, rdx
    shr rcx, 1


    .ciclo:
        cmp rcx, NULL ;chequeos si ya termine
        je .fin

        PMOVZXBW xmm0, [rdi]
        ;xmm0: | B | G | R | A | B | G | R | A | pixel i e i + 1
        movdqu xmm2, [mascara_A]
        pand xmm0, xmm2
        ;xmm2: | B | G | R | 0 | B | G | R | 0 | pixels sin A
        phaddw xmm0, xmm0
        phaddw xmm0, xmm0
        ;xmm0: | B1 + G1 + R1 | B2 + G2 + R2 |  B1 + G1 + R1 | B2 + G2 + R2  |...|
        ;xmm0: | T1 | T2 | T1 | T2 | T1 | T2 | T1 | T2 |
        pmovzxwd xmm3, xmm0 
        ;xmm2: | 00 00 00 T1 | 00 00 00 T2 | 00 00 00 T1 | 00 00 00 T2 |
        CVTDQ2PD xmm3, xmm3
        movdqu xmm4, [mascara_div_3]
        CVTDQ2PD xmm4, xmm4
        divpd xmm3, xmm4
        CVTPD2DQ xmm3, xmm3
        packssdw xmm3, xmm3         ;me quedo con las dos words menos sig
        pxor xmm1, xmm1
        
        movd ebx, xmm3
        shr ebx, 16
        ;muevo para tener el segundo pixel

        movd eax, xmm3

        movdqu xmm1, [mascara_A2]
        ;Dejo en xmm0 los valores de A para ya tenerlos guardados.


        cmp ax, 32
        jl .menor_32p1

        cmp ax, 96
        jl .menor_96p1

        cmp ax, 160
        jl .menor_160p1

        cmp ax, 224
        jl .menor_224p1
        
        ;mayor o igual a 224
        mov r12, rbx
        mov ebx, 255
        sub ax, 224         ; t - 224
        shl ax, 2           ;(t - 224) * 4
        sub bx, ax          ; 255 - ax
        pinsrb xmm1, bl, 2  ;guardo en xmm1 el resultado de ser mayor que 224
        mov rbx, r12
 

    .segundo_pixel:
        cmp bx, 32
        jl .menor_32p2

        cmp bx, 96
        jl .menor_96p2

        cmp bx, 160
        jl .menor_160p2

        cmp bx, 224
        jl .menor_224p2

    ;mayor o igual a 224
        mov rax, 255
        sub bx, 224             ; t - 224         
        shl bx,2                ;(t - 224) * 4
        sub ax, bx              ; 255 - ax
        pinsrb xmm1, al, 6      ;guardo en xmm1 el resultado de ser mayor que 224
        jmp .reset.ciclo

    .menor_32p1:
        shl ax, 2               ;multiplico t * 4
        add ax, 128              ;t + 128
        pinsrb xmm1, al, 0      ;guardo en xmm1 el resultado de ser menor que 32
        jmp .segundo_pixel

    .menor_96p1:
        sub ax, 32                          ;le resto 32 a mi temp
        shl ax, 2                           ;multiplico t * 4
        pinsrb xmm1, al,1                   ;guardo en xmm1 el resultado de ser menor que 96
        pinsrb xmm1, byte [mascara_255], 0  ;coloco 255 en el color R
        jmp .segundo_pixel

    .menor_160p1:
        mov r12, rbx
        sub ax, 96                          ;resto 96 a mi temp
        shl ax, 2                           ;multiplico mi t * 4
        pinsrb xmm1, al, 2                  ;guardo mi temp en el color B
        pinsrb xmm1, byte [mascara_255],1   ;coloco 255 en el color G
        mov rbx, 255
        sub bx, ax                          ; 255 - (t - 96) * 4
        pinsrb xmm1, bl, 0                  ;guardo el resultado en el color R 
        mov rbx, r12
        jmp .segundo_pixel

    .menor_224p1:
        mov r12, rbx
        pinsrb xmm1, byte [mascara_255],2   ;guardo 255 en el color B
        mov rbx, 255
        sub ax, 160                         ;t - 160
        shl ax,2                            ;(t - 160) * 4
        sub bx, ax                          ;255 - (t - 160) * 4
        pinsrb xmm1, bl, 1                  ;guardo el resultado en el color G
        mov rbx, r12
        jmp .segundo_pixel

    ;PIXEL 2
    ;Repito lo mismo que hice en el PIXEL 1 pero para el PIXEL 2
    .menor_32p2:
        shl bx, 2                           
        add bx, 128
        pinsrb xmm1, bl,4
        jmp .reset.ciclo

    .menor_96p2:
        sub bx, 32
        shl bx, 2
        pinsrb xmm1, bl,5
        pinsrb xmm1, byte [mascara_255],4
        jmp .reset.ciclo

    .menor_160p2:
        sub bx, 96
        shl bx, 2
        pinsrb xmm1, bl, 6
        pinsrb xmm1, byte [mascara_255],5
        mov rax, 255
        sub ax, bx
        pinsrb xmm1, al,4
        jmp .reset.ciclo

    .menor_224p2:
        pinsrb xmm1, byte[mascara_255],6
        mov rax, 255
        sub bx, 160
        shl bx,2
        sub ax, bx
        pinsrb xmm1, al, 5
        jmp .reset.ciclo

    .reset.ciclo:
        
        movq [rsi], xmm1
        add rsi, 8
        add rdi, 8
        dec rcx
        jmp .ciclo
   
    .fin:
        pop r12
        pop rbx
        pop rbp
        ret
