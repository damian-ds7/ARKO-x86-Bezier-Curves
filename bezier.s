bits 64
section .data
step: dd 0.0001
zero: dd 0.0
one: dd 1.0

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

	movss xmm0, dword [zero] ; t
	movss xmm1, dword [step] ; step

	cmp rsi, 3
	je three_points_x

	cmp rsi, 4
	je four_points_x

	cmp rsi, 5
	je five_points_x

%macro inc_t 1
	addss xmm0, xmm1
	movss xmm3, dword [one]
	cmpss xmm3, xmm0, 2
	movq rax, xmm3
	cmp rax, 0
	je %1
	jmp draw_points
%endmacro

%macro draw_macro 0
	mov r12, rdi ; copy pixel start address

	mov rax, r8
	mul r11
	mov r11, rax

	add r12, r11
	sal r10, 2
	add r12, r10

	mov [r12], r9d
%endmacro

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
	draw_macro

two_points_next:
	inc_t two_points_x

three_points_x: ; B(t) = (1 - t)^2*P0 + 2*(1 - t)*t*P1 + t^2*P2
	movss xmm2, [one]
	subss xmm2, xmm0 ; 1 - t

	cvtsi2ss xmm4, [rbx]
	cvtsi2ss xmm5, [rbx + 4]
	cvtsi2ss xmm6, [rbx + 8]

	mulss xmm4, xmm2 ; (1 - t)*X0
	mulss xmm4, xmm2 ; (1 - t)^2*X0

	mulss xmm5, xmm0 ; t*X1
	mulss xmm5, xmm2 ; (1 - t)*t*X1
	addss xmm5, xmm5 ; 2*(1 - t)*t*X1

	mulss xmm6, xmm0 ; t*X2
	mulss xmm6, xmm0 ; t^2*X2

	addss xmm4, xmm5
	addss xmm4, xmm6

	cvtss2si r10, xmm4

three_points_y:
	cvtsi2ss xmm4, [rcx]
	cvtsi2ss xmm5, [rcx + 4]
	cvtsi2ss xmm6, [rcx + 8]

	mulss xmm4, xmm2 ; (1 - t)*Y0
	mulss xmm4, xmm2 ; (1 - t)^2*Y0

	mulss xmm5, xmm0 ; t*Y1
	mulss xmm5, xmm2 ; (1 - t)*t*Y1
	addss xmm5, xmm5 ; 2*(1 - t)*t*Y1

	mulss xmm6, xmm0 ; t*Y2
	mulss xmm6, xmm0 ; t^2*Y2

	addss xmm4, xmm5
	addss xmm4, xmm6

	cvtss2si r11, xmm4

three_points_draw:
	draw_macro

three_points_next:
	inc_t three_points_x

four_points_x: ; B(t) = (1 - t)^3*P0 + 3*(1 - t)^2*t*P1 + 3*(1 - t)*t^2*P2 + t^3*P3
	movss xmm2, [one]
	subss xmm2, xmm0 ; 1 - t

	cvtsi2ss xmm4, [rbx]
	cvtsi2ss xmm5, [rbx + 4]
	cvtsi2ss xmm6, [rbx + 8]
	cvtsi2ss xmm7, [rbx + 12]

	mulss xmm4, xmm2 ; (1 - t)*X0
	mulss xmm4, xmm2 ; (1 - t)^2*X0
	mulss xmm4, xmm2 ; (1 - t)^3*X0

	xorps xmm8, xmm8

	mulss xmm5, xmm0 ; t*X1
	mulss xmm5, xmm2 ; (1 - t)*t*X1
	mulss xmm5, xmm2 ; (1 - t)^2*t*X1
	addss xmm8, xmm5
	addss xmm5, xmm5 ; 2*(1 - t)*t*X1
	addss xmm5, xmm8 ; 3*(1 - t)*t*X1

	xorps xmm8, xmm8

	mulss xmm6, xmm0 ; t*X2
	mulss xmm6, xmm0 ; t^2*X2
	mulss xmm6, xmm2 ; (1 - t)*t^2*X2
	addss xmm8, xmm6
	addss xmm6, xmm6 ; 2*(1 - t)*t^2*X2
	addss xmm6, xmm8 ; 3*(1 - t)*t^2*X2

	mulss xmm7, xmm0 ; t*X3
	mulss xmm7, xmm0 ; t^2*X3
	mulss xmm7, xmm0 ; t^3*X3

	addss xmm4, xmm5
	addss xmm4, xmm6
	addss xmm4, xmm7

	cvtss2si r10, xmm4

four_points_y:
	cvtsi2ss xmm4, [rcx]
	cvtsi2ss xmm5, [rcx + 4]
	cvtsi2ss xmm6, [rcx + 8]
	cvtsi2ss xmm7, [rcx + 12]

	mulss xmm4, xmm2 ; (1 - t)*Y0
	mulss xmm4, xmm2 ; (1 - t)^2*Y0
	mulss xmm4, xmm2 ; (1 - t)^3*Y0

	xorps xmm8, xmm8

	mulss xmm5, xmm0 ; t*Y1
	mulss xmm5, xmm2 ; (1 - t)*t*Y1
	mulss xmm5, xmm2 ; (1 - t)^2*t*Y1
	addss xmm8, xmm5
	addss xmm5, xmm5 ; 2*(1 - t)*t*Y1
	addss xmm5, xmm8 ; 3*(1 - t)*t*Y1

	xorps xmm8, xmm8

	mulss xmm6, xmm0 ; t*Y2
	mulss xmm6, xmm0 ; t^2*Y2
	mulss xmm6, xmm2 ; (1 - t)*t^2*Y2
	addss xmm8, xmm6
	addss xmm6, xmm6 ; 2*(1 - t)*t^2*Y2
	addss xmm6, xmm8 ; 3*(1 - t)*t^2*Y2

	mulss xmm7, xmm0 ; t*Y3
	mulss xmm7, xmm0 ; t^2*Y3
	mulss xmm7, xmm0 ; t^3*Y3

	addss xmm4, xmm5
	addss xmm4, xmm6
	addss xmm4, xmm7

	cvtss2si r11, xmm4

four_points_draw:
	draw_macro

four_points_next:
	inc_t four_points_x

five_points_x: ; B(t) = (1 - t)^4*P0 + 4*(1 - t)^3*t*P1 + 6*(1 - t)^2*t^2*P2 + 4(1−t)*t^3*P3 + t^4*P4
	movss xmm2, [one]
	subss xmm2, xmm0 ; 1 - t

	cvtsi2ss xmm4, [rbx]
	cvtsi2ss xmm5, [rbx + 4]
	cvtsi2ss xmm6, [rbx + 8]
	cvtsi2ss xmm7, [rbx + 12]
	cvtsi2ss xmm8, [rbx + 16]

	mulss xmm4, xmm2 ; (1 - t)*X0
	mulss xmm4, xmm2 ; (1 - t)^2*X0
	mulss xmm4, xmm2 ; (1 - t)^3*X0
	mulss xmm4, xmm2 ; (1 - t)^4*X0

	mulss xmm5, xmm0 ; t*X1
	mulss xmm5, xmm2 ; (1 - t)*t*X1
	mulss xmm5, xmm2 ; (1 - t)^2*t*X1
	mulss xmm5, xmm2 ; (1 - t)^3*t*X1
	addss xmm5, xmm5 ; 2*(1 - t)^3*t*X1
	addss xmm5, xmm5 ; 4*(1 - t)^3*t*X1

	xorps xmm9, xmm9

	mulss xmm6, xmm0 ; t*X2
	mulss xmm6, xmm0 ; t^2*X2
	mulss xmm6, xmm2 ; (1 - t)*t^2*X2
	mulss xmm6, xmm2 ; (1 - t)^2*t^2*X2
	addss xmm6, xmm6 ; 2*(1 - t)^2*t^2*X2
	addss xmm9, xmm6
	addss xmm6, xmm6 ; 4*(1 - t)^2*t^2*X2
	addss xmm6, xmm9 ; 6*(1 - t)^2*t^2*X2

	mulss xmm7, xmm0 ; t*X3
	mulss xmm7, xmm0 ; t^2*X3
	mulss xmm7, xmm0 ; t^3*X3
	mulss xmm7, xmm2 ; (1 - t)*t^3*X3
	addss xmm7, xmm7 ; 2*(1 - t)*t^3*X3
	addss xmm7, xmm7 ; 4*(1 - t)*t^3*X3

	mulss xmm8, xmm0 ; t*X4
	mulss xmm8, xmm0 ; t^2*X4
	mulss xmm8, xmm0 ; t^3*X4
	mulss xmm8, xmm0 ; t^4*X4

	addss xmm4, xmm5
	addss xmm4, xmm6
	addss xmm4, xmm7
	addss xmm4, xmm8

	cvtss2si r10, xmm4

five_points_y:
	cvtsi2ss xmm4, [rcx]
	cvtsi2ss xmm5, [rcx + 4]
	cvtsi2ss xmm6, [rcx + 8]
	cvtsi2ss xmm7, [rcx + 12]
	cvtsi2ss xmm8, [rcx + 16]

	mulss xmm4, xmm2 ; (1 - t)*Y0
	mulss xmm4, xmm2 ; (1 - t)^2*Y0
	mulss xmm4, xmm2 ; (1 - t)^3*Y0
	mulss xmm4, xmm2 ; (1 - t)^4*Y0

	mulss xmm5, xmm0 ; t*Y1
	mulss xmm5, xmm2 ; (1 - t)*t*Y1
	mulss xmm5, xmm2 ; (1 - t)^2*t*Y1
	mulss xmm5, xmm2 ; (1 - t)^3*t*Y1
	addss xmm5, xmm5 ; 2*(1 - t)^3*t*Y1
	addss xmm5, xmm5 ; 4*(1 - t)^3*t*Y1

	xorps xmm9, xmm9

	mulss xmm6, xmm0 ; t*XY2
	mulss xmm6, xmm0 ; t^2*Y2
	mulss xmm6, xmm2 ; (1 - t)*t^2*Y2
	mulss xmm6, xmm2 ; (1 - t)^2*t^2*Y2
	addss xmm6, xmm6 ; 2*(1 - t)^2*t^2*Y2
	addss xmm9, xmm6
	addss xmm6, xmm6 ; 4*(1 - t)^2*t^2*Y2
	addss xmm6, xmm9 ; 6*(1 - t)^2*t^2*Y2

	mulss xmm7, xmm0 ; t*Y3
	mulss xmm7, xmm0 ; t^2*Y3
	mulss xmm7, xmm0 ; t^3*Y3
	mulss xmm7, xmm2 ; (1 - t)*t^3*Y3
	addss xmm7, xmm7 ; 2*(1 - t)*t^3*Y3
	addss xmm7, xmm7 ; 4*(1 - t)*t^3*Y3

	mulss xmm8, xmm0 ; t*Y4
	mulss xmm8, xmm0 ; t^2*Y4
	mulss xmm8, xmm0 ; t^3*Y4
	mulss xmm8, xmm0 ; t^4*Y4

	addss xmm4, xmm5
	addss xmm4, xmm6
	addss xmm4, xmm7
	addss xmm4, xmm8

	cvtss2si r11, xmm4

five_points_draw:
	draw_macro

five_points_next:
	inc_t five_points_x

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