prog: build/main.o
	gcc build/main.o -o prog

build/main.o: src/main.asm src/chip8.inc
	mkdir -p build
	nasm -felf64 -g -F dwarf -I src/ src/main.asm -o build/main.o

clean:
	rm -f build/*.o prog

.PHONY: clean