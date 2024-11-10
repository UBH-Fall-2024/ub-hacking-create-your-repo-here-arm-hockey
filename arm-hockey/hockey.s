	.data
	.text
	.global hockey
	.global gpio_init

hockey:
	push {lr}

	bl gpio_init

	pop {lr}
	mov pc, lr
