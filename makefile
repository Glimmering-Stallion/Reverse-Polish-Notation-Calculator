# Makefile_nasm for .asm and .c files

FILE1 = main
FILE2 = funcs
CFILE = add_c

all: $(FILE1).asm $(FILE2).asm
	nasm -f elf64 -g $(FILE1).asm -o $(FILE1).o
	nasm -f elf64 -g $(FILE2).asm -o $(FILE2).o
	gcc -m64 -o $(FILE1) $(FILE1).o $(FILE2).o $(CFILE).c

run: $(FILE1)
	./$(FILE1)

clean:
	rm *.o