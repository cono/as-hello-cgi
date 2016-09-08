.global _start

.text
_start:

# Print header
# rax = 1 - syscall write(rdi - file descriptor, rsi - char*, rdx - length)
	movq	$1, %rax
	movq	$1, %rdi
	movq	$header, %rsi
	movq	$header_len, %rdx
	syscall

# Taking amount of arguments from top of the stack
	popq	%rcx

# Skipping all arguments
skip_argument:
	popq	%rsi
	loop	skip_argument

# Skipping 0 byte between argument and environment variables
	popq	%rsi

env_loop:
	popq	%rsi
	cmpq	$0, %rsi
	je	print_unknown

	movq	$query_string, %rdi
	movq	$qlen, %rcx
	repe cmpsb
	jne	env_loop

check_param:
	movq	$parameter, %rdi
	movq	$parameter_len, %rcx
	repe cmpsb
	je	scan_name

	xorq	%rax, %rax

amp_search:
	lodsb
	cmpb	$0, %al
	je	print_unknown
	cmpb	$38, %al
	je	check_param
	jmp	amp_search

scan_name:
	movq	%rsi, %rdx

loop_name:
	lodsb
	cmpb	$0, %al
	je	print_name
	cmpb	$38, %al
	jne	loop_name

print_name:
	movq	$1, %rax
	movq	$1, %rdi
	xchgq	%rsi, %rdx
	subq	%rsi, %rdx
	decq	%rdx
	syscall
	jmp	exit

print_unknown:
	movq	$1, %rax
	movq	$1, %rdi
	movq	$unknown, %rsi
	movq	$unknown_len, %rdx
	decq	%rdx
	syscall

exit:
	movq	$1, %rax
	movq	$1, %rdi
	movq	$exclamation, %rsi
	movq	$1, %rdx
	syscall

	movq	$60, %rax
	xorq	%rdi, %rdi
	syscall
.data
header:
	.ascii	"Content-Type: text/plain\n\nHello "
	header_len = . - header

unknown:
	.ascii	"Unknown"
exclamation:
	.ascii	"!"
	unknown_len = . - unknown

parameter:
	.ascii	"name="
	parameter_len = . - parameter

query_string:
	.ascii	"QUERY_STRING="
	qlen = . - query_string
