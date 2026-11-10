prog: build/main.o
	gcc build/main.o -Wall -o prog

build/main.o: src/main.asm
	nasm -felf64 src/main.asm -o build/main.o

clean:
	rm build/main.o prog