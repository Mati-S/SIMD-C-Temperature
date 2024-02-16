
section .text

global invertirQW_asm

; void invertirQW_asm(uint64_t* p)

; PINSRQ - Packed INSeRt Qword
; PINSRQ xmm1, r/m64, imm8
; inserta el QuadWord (64 bits) en xmm1[15:8] si imm8[0] es 1, y en xmm1[7:0] si imm8[0] es 0.
invertirQW_asm:
    push rbp
    mov rbp, rsp

    PINSRQ xmm1, [rdi], 1
    PINSRQ xmm1, [rdi + 8], 0

    movdqu [rdi], xmm1

    pop rbp
	ret
