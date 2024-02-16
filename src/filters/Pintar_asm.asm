section .data

; Orden : B-G-R-A
mascara_negro: db 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255, 0, 0, 0, 255
mascara_blanco: db 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255

mascara_columna_izq: db 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255
mascara_columna_der: db 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 255, 0, 0, 0, 255
; 0 es NEGRO
; 255 es BLANCO
section .text
global Pintar_asm

; void Pintar_asm(uint8_t *src, uint8_t *dst, int width, int height, int src_row_size, int dst_row_size);
; rdi = src, rsi = dst, rdx = width, rcx = height, r8 = src_row_size, r9 = dst_row_size
Pintar_asm:
	push rbp
	mov rbp, rsp
	push r14 ; lo uso para: indice de ancho
	push r15 ; lo uso para: indice de alto
	push rbx ; lo uso para: alto - 2
	sub rsp, 8

	; Cargamos las mascaras
	movdqu xmm7, [mascara_negro]
	movdqu xmm8, [mascara_blanco]
	movdqu xmm9, [mascara_columna_izq]
	movdqu xmm10, [mascara_columna_der]

	mov r14, 0 	; indiceAncho
	mov r15, 0 	; indiceAlto

	mov rbx, rcx ; rbx = alto
	sub rbx, 2	 ; rbx = alto - 2

	mov r11, rdx ; r11 = ancho
	sub r11, 4   ; r11 = ancho - 4

    .ciclo:
	cmp r15, rcx     ; vamos loopeando de 0 hasta el Alto
	je .fin

    ; Pintamos las primeras 2 filas de negro
	cmp r15, 2	; dado q las primeras 2 filas (0 y 1) se tienen q pintar de negro
	jb .pintarFilaNegro

    ; Pintamos las ultimas 2 filas de negro si estamos en dicho intervalo final
	cmp r15, rbx  ; indiceAlto >= Alto - 2
	jge .pintarFilaNegro

    ; Pintamos las primeras 4 columnas de negro si estamos en dicho intervalo
 	cmp r14, 2 ; indiceAncho < 2
 	jb .pintarPrimerosCuatroPixelesNegroYBlanco

    ; Pintamos las ultimas 4 columnas de negro si estamos en dicho intervalo
 	cmp r14, r11 ; indiceAncho >= ancho - 4
 	jge .pintarUltimosCuatroPixelesBlancoYNegro

 	; Estamos en un caso del medio
    movdqu [rsi], xmm8

    add rsi, 16 		; avanzar dst 4 pixeles = 16 bytes
    add r14, 4 			; avanzamos indiceAncho
    cmp r14, rdx 		; si indiceAncho < ancho sigo loopeando
    jb .ciclo

    xor r14, r14
    inc r15
    jmp .ciclo

    .pintarFilaNegro:
	movdqu [rsi], xmm7 	; guardar 4 pixeles negros en dst

	add rsi, 16 		; avanzar dst 4 pixeles = 16 bytes
	add r14, 4 			; avanzamos indiceAncho
	cmp r14, rdx 		; si indiceAncho < ancho sigo loopeando
	jb .pintarFilaNegro

	xor r14, r14  ; reseteo el indiceAncho en 0 para procesar la fila siguiente
	inc r15       ; indiceAlto++
	jmp .ciclo

    .pintarPrimerosCuatroPixelesNegroYBlanco:
    movdqu [rsi], xmm9
    ; Dado que estamos en los primeros 4 pixeles de la fila:
    add rsi, 16
    add r14, 4
    jmp .ciclo

    .pintarUltimosCuatroPixelesBlancoYNegro:
    movdqu [rsi], xmm10

    add rsi, 16
    add r14, 4
    ; Dado que estamos en los ultimos 4 pixeles de la fila:
    xor r14, r14
    inc r15
    jmp .ciclo

    .fin:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop rbp
	ret
