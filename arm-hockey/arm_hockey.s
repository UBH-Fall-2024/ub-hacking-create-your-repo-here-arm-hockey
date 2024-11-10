    .data

p1_get_ready:      .string "Player 1: ?", 0
p2_get_ready:      .string "Player 2: ?", 0


cc_smiley:          .byte   0x0a, 0x0A, 0x0A, 0x00, 0x11, 0x0e, 0x00, 0x00
cc_check:           .byte   0x00, 0x01, 0x03, 0x016, 0x1c, 0x08, 0x00, 0x00


    .text

    .global arm_hockey

    .global gpio_a_init

    ; lcd.
    .global         lcd_output_string
    .global         lcd_init
    .global         lcd_cmd
    .global         lcd_data
    .global         lcd_second_line
    .global         lcd_store_cc
    .global         lcd_set_pos


; pointers
ptr_p1_get_ready:       .word       p1_get_ready
ptr_p2_get_ready:       .word       p2_get_ready

ptr_cc_smiley:          .word       cc_smiley
ptr_cc_check:           .word       cc_check

arm_hockey:
    push    {lr}
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


    mov     r0, #10
    mov     r1, #0
    bl      lcd_set_pos

    mov     r0, #0
    bl      lcd_data

    mov     r0, #10
    mov     r1, #1
    bl      lcd_set_pos

    mov     r0, #0
    bl      lcd_data




    bl      gpio_a_init

loop: b loop

    pop     {pc}















    .end
