DEBUG=-g

hello: hello.s
	as -o hello.o hello.s
	ld -o hello hello.o

debug: hello.s
	as $(DEBUG) -o hello.o hello.s
	ld -o hello hello.o
clean:
	rm -rf hello.o hello
