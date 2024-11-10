    .data

p1_get_ready:      .string "Player 1: ?", 0
p2_get_ready:      .string "Player 2: ?", 0

p1_score:           .byte    0
p2_score:           .byte    0

start_p1_score:     .string "Player 1: "
str_p1_score:       .byte   '0', 0

start_p2_score:     .string "Player 2: "
str_p2_score:       .byte   '0', 0



cc_smiley:          .byte   0x0a, 0x0A, 0x0A, 0x00, 0x11, 0x0e, 0x00, 0x00
cc_check:           .byte   0x00, 0x01, 0x03, 0x016, 0x1c, 0x08, 0x00, 0x00


    .text

    .global arm_hockey

    .global gpio_a_init
    .global gpio_b_init
    .global         delay_us


    ; lcd.
    .global         lcd_output_string
    .global         lcd_init
    .global         lcd_cmd
    .global         lcd_data
    .global         lcd_second_line
    .global         lcd_store_cc
    .global         lcd_set_pos

    ; utils.
    .global         int2string

; pointers
ptr_p1_get_ready:       .word       p1_get_ready
ptr_p2_get_ready:       .word       p2_get_ready

; score.
ptr_p1_score:           .word       p1_score
ptr_p2_score:           .word       p2_score
ptr_str_p1_score:       .word       str_p1_score
ptr_str_p2_score:       .word       str_p2_score

ptr_start_p1_score:     .word       start_p1_score
ptr_start_p2_score:     .word       start_p2_score

; custom characters.
ptr_cc_smiley:          .word       cc_smiley
ptr_cc_check:           .word       cc_check

arm_hockey:
    push    {lr}
    bl      gpio_a_init
    bl      gpio_b_init

    bl      lcd_init

    mov     r0, #0x1
    bl      lcd_cmd

    ; store cc.
    mov     r0, #0x40
    ldr     r1, ptr_cc_check
    bl      lcd_store_cc

    mov     r0, #0x1
    bl      lcd_cmd

    ldr     r0, ptr_p1_get_ready
    bl      lcd_output_string
    bl      lcd_second_line
    ldr     r0, ptr_p2_get_ready
    bl      lcd_output_string



    ; wait for players to be ready.
    bl      ah_player_ready

    bl      ah_start_fan

    ; show score.
    mov         r0, #0
    mov         r1, #0
    bl          lcd_set_pos

    ldr         r0, ptr_start_p1_score
    bl          lcd_output_string

    mov         r0, #0
    mov         r1, #1
    bl          lcd_set_pos

    ldr         r0, ptr_start_p2_score
    bl          lcd_output_string


loop:
    mov         r1, #0x5000
    movt        r1, #0x4000
    ldrb        r0, [r1, #(0x3 << 2)]
    tst         r0, #1
    beq         add_p1

    tst         r0, #2
    beq         add_p2

    b           loop

add_p1:
    push        {lr}
    bl          ah_increment_p1_score
    mov         r0, #0x8480
    movt        r0, #0x1e
    bl          delay_us
    pop         {lr}
    b loop
add_p2:
    push        {lr}
    bl          ah_increment_p2_score
    mov         r0, #0x8480
    movt        r0, #0x1e
    bl          delay_us
    pop         {lr}
    b loop


    pop     {pc}




set_p1_ready:
    push        {lr}
    mov         r0, #10
    mov         r1, #0
    bl          lcd_set_pos

    mov         r0, #0
    bl          lcd_data
    pop         {pc}



set_p2_ready:
    push        {lr}
    mov         r0, #10
    mov         r1, #1
    bl          lcd_set_pos

    mov         r0, #0
    bl          lcd_data
    pop         {pc}



ah_player_ready:
    push        {r4, lr}
    mov         r4, #0
player_ready_poll:
    mov         r1, #0x40004000
    ldr         r0, [r1, #(0xc0 << 2)]
    push        {r0}
    tst         r0, #(1 << 6)
    itt         ne
    orrne       r4, #1
    blne        set_p1_ready

    pop         {r0}
    tst         r0, #(1 << 7)
    itt         ne
    orrne       r4, #2
    blne        set_p2_ready

    cmp         r4, #3
    bne         player_ready_poll

    pop         {r4, pc}


ah_start_fan:
    mov         r1, #0x40004000
    ldrb        r0, [r1, #((1 << 5) << 2)]
    orr         r0, #(1 << 5)
    strb        r0, [r1, #((1 << 5) << 2)]
    mov         pc, lr





ah_increment_p1_score:
    push        {lr}
    ldr         r1, ptr_str_p1_score
    ldrb        r0, [r1]
    add         r0, #1
    strb        r0, [r1]

    ; update lcd for p1 score.
    mov         r0, #0
    mov         r1, #0
    bl          lcd_set_pos

    ldr         r0, ptr_start_p1_score
    bl          lcd_output_string



    pop         {pc}


ah_increment_p2_score:
    push        {lr}
    ldr         r1, ptr_str_p2_score
    ldrb        r0, [r1]
    add         r0, #1
    strb        r0, [r1]

    ; update lcd for p2 score.
    mov         r0, #0
    mov         r1, #1
    bl          lcd_set_pos
    ldr         r0, ptr_start_p2_score
    bl          lcd_output_string

    pop         {pc}



    .end
