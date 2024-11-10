	.data
	.text
	.global gpio_init

; trigger ir sensor on falling/rising edge

gpio_init:
	push {lr}

	pop {lr}
	mov pc, lr
