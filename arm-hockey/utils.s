    .text

    .global         delay_us
    .global         int2string





; r0 holds amount to delay for in microseconds
; Note: this is an approx. calculation
delay_us:
    push    {r1}
    mov     r1, #0

delay_us_Loop:
    add     r1, #1
    cmp     r0, r1
    bgt     delay_us_Loop

    pop     {r1}
    mov     pc, lr




;***************************************************************************************************
; Function name: int2string
; Function behavior: Converts an integer to a string. First counts number of digits in the string by
; dividing by 10. Then reverse iterates string to correctly place digits. Uses formula for remainder
; to iterate get decimal place value at each junction n mod 10 = n - (10*floor (n/10)). Stores in
; string index, divides number by 10 and loops again.
; SPECIAL CASE: Passed integer is 0, store '0' and \0
;
; Function inputs:
; r0 : integer for conversion
; r1 : Address of string storage
;
; Function returns: none
;
; Registers used:
; r4 : Holds copy of integer for digit count/remainder to store in string
; r5 : digit counter/loop counter/string offset
; r6 : holds 10 for division and multiplication
;
; Subroutines called:
; none
;
; REMINDER: Push used registers r4-r11 to stack if used *PUSH/POP {r4, r5} or PUSH/POP {r4-r11})
; REMINDER: If calling another function from inside, PUSH/POP {lr}. To return from function MOV pc, lr
;***************************************************************************************************
int2string:
    PUSH    {r4-r6, lr}                         ; Store registers on stack


    movw    r6, #10                     ; Load decimal 10 into r6 for div/mul

    ; Use division do determine number of places in digit.
    mov     r4, r0                      ; Load integer into r4
    movw    r5, #0                      ; Load 0 for use as counter/offset

digit_count_begin:
    cmp     r4, #0                      ; If r4 == 0
    beq     digit_count_end             ; Stop counting digits
    ; Otherwise, divide integer by 10 and increment counter
    sdiv    r4, r4, r6                  ; r4/10
    add     r5, #1                      ; Increment counter
    b       digit_count_begin           ; Restart loop

digit_count_end:
    ; Special case, number entered is 0
    cmp     r5, #0                      ; r5 != 0?
    bne     int2string_null_char        ; skip next step
    movw    r4, #'0'                    ; Load ASCII '0'
    strb    r4, [r1]                    ; Store ASCII '0'
    strb    r5, [r1, #1]                ; Store null character
    b       int2string_finish_and_return; Finish and return

    ; Store the null character at size string index.
int2string_null_char:
    movw    r4, #0                      ; Load \0 character
    strb    r4, [r1, r5]                ; Store null terminator
    add     r5, #-1                     ; Decrement counter

    ; For each string index, get the value of int mod 10 and store at index, then reduce
    ; integer by power of 10 with division until all digits have been stringified
int2string_main_loop:

    ; Begin modulus formula
    sdiv    r4, r0, r6                  ; floor (n/10)
    mul     r4, r4, r6                  ; 10 * floor(n/10)
    sub     r4, r0, r4                  ; n - 10*floor(n/10)

    ; Convert to ascii character and store
    add     r4, #'0'                    ; Int + ASCII '0' to get ASCII value
    strb    r4, [r1, r5]                ; Store character at address + offset

    ; Decrease int by power of 10
    sdiv    r0, r0, r6                  ; int / 10

    ; Decrement and compare
    add     r5, #-1                     ; Decrement
    cmp     r5, #-1                     ; If r5 != -1
    bne     int2string_main_loop        ; Loop again


int2string_finish_and_return:

    ; Pop used registers

    POP     {r4-r6, lr}                         ; Restore lr from stack
    mov     pc, lr



    .end
