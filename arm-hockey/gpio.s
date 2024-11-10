    .text
    .global gpio_a_init
    .global gpio_b_init

    ; addresses offsets for GPIOs
RCGC:   .equ 0x608    ;GPIO clock gating control
DIR:    .equ 0x400     ;port direction register
DEN:    .equ 0x51C     ;port digital enable
DATA:   .equ 0x3FC    ;gpio data offset
PUR:    .equ 0x510     ;pull-up resistor offset

gpio_a_init:
    ;set r1 to the clock gating control base
    mov r1, #0xE000
    movt r1, #0x400F

    ;enable the clock for the GPIO ports
    ldrb    r0, [r1, #RCGC]     ;load current value of RCGC Offset
    orr     r0, #0x1           ;port 1 to be enabled
    strb    r0, [r1, #RCGC]     ;set bits

    ;initialize port a.
    mov     r1, #0x4000
    movt    r1, #0x4000

    ; set digital.
    ldrb    r0, [r1, #DEN]
    orr     r0, #(1 << 5)
    orr     r0, #(1 << 6)
    orr     r0, #(1 << 7)
    strb    r0, [r1, #DEN]      ;set digital for pins 1-3

    ; set direction (0 = input, 1 = output).
    ldrb    r0, [r1, #DIR]
    orr     r0, #(1 << 5)
    bic     r0, #(1 << 6)
    bic     r0, #(1 << 7)
    strb    r0, [r1, #DIR]

    mov     pc, lr


gpio_b_init:
    ;set r1 to the clock gating control base
    mov r1, #0xE000
    movt r1, #0x400F

    ;enable the clock for the GPIO ports
    ldrb    r0, [r1, #RCGC]     ;load current value of RCGC Offset
    orr     r0, #0x2            ;port b to be enabled
    strb    r0, [r1, #RCGC]     ;set bits

    ;initialize port b.
    mov     r1, #0x5000
    movt    r1, #0x4000

    ; set digital.
    ldrb    r0, [r1, #DEN]
    orr     r0, #(1 << 0)
    orr     r0, #(1 << 1)
    strb    r0, [r1, #DEN]      ;set digital for pins 1-3

    ; set direction (0 = input, 1 = output).
    ldrb    r0, [r1, #PUR]
    orr     r0, #(1 << 0)
    orr     r0, #(1 << 1)
    strb    r0, [r1, #PUR]

    mov     pc, lr


    .end
