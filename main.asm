section .text
global vec3_add
global vec3_sub
global vec3_mul_scalar
global vec3_div_scalar
global vec3_dot
global vec3_cross
global vec3_length
global vec3_length_squared
global vec3_distance
global vec3_normalize
global vec3_lerp
global vec3_reflect

vec3_add:
    movss xmm0, [rsi]
    movss xmm1, [rsi+4]
    movss xmm2, [rsi+8]   
    
    addss xmm0, [rdx]      
    addss xmm1, [rdx+4]    
    addss xmm2, [rdx+8]    
    
    movss [rdi], xmm0
    movss [rdi+4], xmm1
    movss [rdi+8], xmm2
    ret

vec3_sub:
    movss xmm0, [rsi]       ; Load a.x
    movss xmm1, [rsi+4]     ; Load a.y
    movss xmm2, [rsi+8]     ; Load a.z
    
    subss xmm0, [rdx]       ; a.x - b.x
    subss xmm1, [rdx+4]     ; a.y - b.y
    subss xmm2, [rdx+8]     ; a.z - b.z
    
    movss [rdi], xmm0       ; Store result.x
    movss [rdi+4], xmm1     ; Store result.y
    movss [rdi+8], xmm2     ; Store result.z
    ret

vec3_mul_scalar:
    movss xmm1, [rsi]       ; Load v.x
    movss xmm2, [rsi+4]     ; Load v.y
    movss xmm3, [rsi+8]     ; Load v.z
    
    mulss xmm1, xmm0        ; v.x * scalar
    mulss xmm2, xmm0        ; v.y * scalar
    mulss xmm3, xmm0        ; v.z * scalar
    
    movss [rdi], xmm1       ; Store result.x
    movss [rdi+4], xmm2     ; Store result.y
    movss [rdi+8], xmm3     ; Store result.z
    ret

vec3_div_scalar:
    movss xmm1, [rsi]       ; Load v.x
    movss xmm2, [rsi+4]     ; Load v.y
    movss xmm3, [rsi+8]     ; Load v.z
    
    divss xmm1, xmm0        ; v.x / scalar
    divss xmm2, xmm0        ; v.y / scalar
    divss xmm3, xmm0        ; v.z / scalar
    
    movss [rdi], xmm1       ; Store result.x
    movss [rdi+4], xmm2     ; Store result.y
    movss [rdi+8], xmm3     ; Store result.z
    ret


vec3_dot:
    movss xmm0, [rdi]       ; Load a.x
    movss xmm1, [rdi+4]     ; Load a.y
    movss xmm2, [rdi+8]     ; Load a.z
    
    mulss xmm0, [rsi]       ; a.x * b.x
    mulss xmm1, [rsi+4]     ; a.y * b.y
    mulss xmm2, [rsi+8]     ; a.z * b.z
    
    addss xmm0, xmm1        ; (a.x*b.x) + (a.y*b.y)
    addss xmm0, xmm2        ; + (a.z*b.z)
    ret

vec3_cross:
    movss xmm0, [rsi+4]     ; a.y
    movss xmm1, [rsi+8]     ; a.z
    movss xmm2, [rsi]       ; a.x
    
    mulss xmm0, [rdx+8]     ; a.y * b.z
    mulss xmm1, [rdx]       ; a.z * b.x
    mulss xmm2, [rdx+4]     ; a.x * b.y
    
    movss xmm3, [rsi+8]     ; a.z
    movss xmm4, [rsi]       ; a.x
    movss xmm5, [rsi+4]     ; a.y
    
    mulss xmm3, [rdx+4]     ; a.z * b.y
    mulss xmm4, [rdx+8]     ; a.x * b.z
    mulss xmm5, [rdx]       ; a.y * b.x
    
    subss xmm0, xmm3        ; result.x = a.y*b.z - a.z*b.y
    subss xmm1, xmm4        ; result.y = a.z*b.x - a.x*b.z
    subss xmm2, xmm5        ; result.z = a.x*b.y - a.y*b.x
    
    movss [rdi], xmm0
    movss [rdi+4], xmm1
    movss [rdi+8], xmm2
    ret

vec3_length_squared:
    movss xmm0, [rdi]       ; v.x
    movss xmm1, [rdi+4]     ; v.y
    movss xmm2, [rdi+8]     ; v.z
    
    mulss xmm0, xmm0        ; v.x * v.x
    mulss xmm1, xmm1        ; v.y * v.y
    mulss xmm2, xmm2        ; v.z * v.z
    
    addss xmm0, xmm1
    addss xmm0, xmm2
    ret


vec3_length:
    call vec3_length_squared
    sqrtss xmm0, xmm0
    ret

vec3_distance:
    push rbx
    sub rsp, 24 
    
    mov rbx, rsp 
    mov rdx, rsi          
    mov rsi, rdi            
    mov rdi, rbx           
    
    call vec3_sub
    mov rdi, rbx
    call vec3_length
    
    add rsp, 24
    pop rbx
    ret

vec3_normalize:
    push rbx
    push r12
    mov rbx, rdi 
    mov r12, rsi 
    
    mov rdi, rsi
    call vec3_length 
    
    mov rdi, rbx
    mov rsi, r12 
    call vec3_div_scalar
    
    pop r12
    pop rbx
    ret

vec3_lerp:
    push rbx
    push r12
    push r13
    sub rsp, 24             ; Allocate temp vector
    
    movss [rsp+16], xmm0    ; Save t
    mov rbx, rdi            ; Save result
    mov r12, rsi            ; Save a
    mov r13, rdx            ; Save b
    
    mov rdi, rsp            ; temp vector
    mov rsi, r13            ; b
    mov rdx, r12            ; a
    call vec3_sub           ; temp = b - a
    
    mov rdi, rsp
    mov rsi, rsp
    movss xmm0, [rsp+16]    ; Load t
    call vec3_mul_scalar    ; temp = temp * t
    
    mov rdi, rbx            ; result
    mov rsi, r12            ; a
    mov rdx, rsp            ; temp
    call vec3_add           ; result = a + temp
    
    add rsp, 24
    pop r13
    pop r12
    pop rbx
    ret

vec3_reflect:
    push rbx
    push r12
    push r13
    sub rsp, 32
    
    mov rbx, rdi            ; Save result
    mov r12, rsi            ; Save v
    mov r13, rdx            ; Save n
    
    mov rdi, r12
    mov rsi, r13
    call vec3_dot 
    
    addss xmm0, xmm0
    movss [rsp+24], xmm0
    
    mov rdi, rsp
    mov rsi, r13
    movss xmm0, [rsp+24]
    call vec3_mul_scalar
    
    mov rdi, rbx            
    mov rsi, r12
    mov rdx, rsp
    call vec3_sub 
    
    add rsp, 32
    pop r13
    pop r12
    pop rbx

    ret
