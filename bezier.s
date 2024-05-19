bits 64
section .data
step: dd 0.0001
one: dd 1.0
zero: dd 0.0

section .text
global bezier

bezier:
    push rbp
    mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14
	push r15

	mov r9d, 0xFF000000
	mov rbx, rdx

	movsxd r8, r8d

begin:
	test rsi, rsi
	jz end

	cmp rsi, 1
	je draw_points

	sub rsp, 32
	mov [rbp - 8], rsi
	mov [rbp - 16], r8
	mov [rbp - 24], rbx ; save x array on stack
	mov [rbp - 32], rcx ; save y array on stack

	movss xmm0, dword [zero] ; t
	movss xmm1, dword [step] ; step

	cmp rsi, 3
	je three_points_start

	cmp rsi, 4
	je four_points_start

	cmp rsi, 5
	je five_points_start

;B(t) = (1 - t)*P0 + t*P1
two_points_x:
	movss xmm2, [one]
	subss xmm2, xmm0 ; 1 - t

	cvtsi2ss xmm4, [rbx]
	cvtsi2ss xmm5, [rbx + 4]

	mulss xmm4, xmm2 ; (1 - t)*X0
	mulss xmm5, xmm0 ; t*X1
	addss xmm4, xmm5 ; (1 - t)*X0 + t*X1

	cvtss2si r10, xmm4

two_points_y:
	cvtsi2ss xmm4, [rcx]
	cvtsi2ss xmm5, [rcx + 4]

	mulss xmm4, xmm2 ; (1 - t)*Y0
	mulss xmm5, xmm0 ; t*Y1
	addss xmm4, xmm5 ; (1 - t)*Y0 + t*Y1

	cvtss2si r11, xmm4

two_points_draw:
	mov r12, rdi ; copy pixel start address

	mov rax, r8
	mul r11
	mov r11, rax

	add r12, r11
	sal r10, 2
	add r12, r10

	mov [r12], r9d

two_points_next:
	addss xmm0, xmm1
	movss xmm3, dword [one]
	cmpss xmm3, xmm0, 2
	movq rax, xmm3
	cmp rax, 0
	je two_points_x
	jmp draw_points

three_points_start: ; B(t) = (1 - t)^2*P0 + 2*(1 - t)*t*P1 + t^2*P2
	jmp load_points

four_points_start: ; B(t) = (1 - t)^3*P0 + 3*(1 - t)^2*t*P1 + 3*(1 - t)*t^2*P2 + t^3*P3
	jmp load_points

five_points_start: ; B(t) = (1 - t)^4*P0 + 4*(1 - t)^3*t*P1 + 6*(1 - t)^2*t^2*P2 + 4(1−t)*t^3*P3 + t^4*P4


load_points:
	mov rsi, [rbp - 8]
	mov r8, [rbp - 16]
	mov rbx, [rbp - 24]
	mov rcx, [rbp - 32]

draw_points:
	xor r10, r10
	xor r11, r11

	mov r10d, [rbx]
	mov r11d, [rcx]

	mov r12, rdi ; copy pixel start address

	mov rax, r8
	mul r11
	mov r11, rax

	add r12, r11
	sal r10, 2
	add r12, r10

	mov [r12], r9d
	mov [r12 + 4], r9d
	mov [r12 - 4], r9d
	mov [r12 + r8], r9d
	mov r13, r8
	neg r13
	mov [r12 + r13], r9d

	lea rbx, [rbx + 4]
	lea rcx, [rcx + 4]

	dec rsi
	test rsi, rsi
	jnz draw_points

end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx

	mov rsp, rbp
	pop rbp
	ret