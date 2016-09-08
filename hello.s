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

# Cycling through the environment lines e.g.:
# HOME=/home/cono
env_loop:
	popq	%rsi
	cmpq	$0, %rsi
	je	print_unknown

# Checking if this variable is a QUERY_STRING
	movq	$query_string, %rdi
	movq	$qlen, %rcx
	repe cmpsb
	jne	env_loop

# If its a QUERY_STRING trying to find our "name=" parameter
check_param:
	movq	$parameter, %rdi
	movq	$parameter_len, %rcx
	repe cmpsb
	je	scan_name

	xorq	%rax, %rax

# If first parameter is not a name, looking for "&" to match next parameter
amp_search:
	lodsb
	cmpb	$0, %al
	je	print_unknown
	cmpb	$38, %al
	je	check_param
	jmp	amp_search

# Looks like we found our parameter, lets start reading the name
scan_name:
	movq	%rsi, %rdx

# Cycling through the line before we reach end of the string or another "&"
loop_name:
	lodsb
	cmpb	$0, %al
	je	print_name
	cmpb	$38, %al
	jne	loop_name

# Name found, lets print it
print_name:
	movq	$1, %rax
	movq	$1, %rdi
	xchgq	%rsi, %rdx
	subq	%rsi, %rdx
	decq	%rdx
	syscall
	jmp	exit

# In case we haven't found name, let's print "Unknown"
print_unknown:
	movq	$1, %rax
	movq	$1, %rdi
	movq	$unknown, %rsi
	movq	$unknown_len, %rdx
	decq	%rdx
	syscall

# Priniting exclamation mark and making exit(0)
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
