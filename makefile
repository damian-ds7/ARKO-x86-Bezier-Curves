CC = gcc
CFLAGS = -m64 -Wall
DFLAGS = -g -O0 -DDEBUG
LIBS = -lallegro -lallegro_image -lallegro_dialog

all: main.o bezier.o
	$(CC) $(CFLAGS) main.o bezier.o -o bezier $(LIBS)

debug: main_debug.o bezier.o
	$(CC) $(CFLAGS) $(DFLAGS) main_debug.o bezier.o -o debug $(LIBS)

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

main_debug.o: main.c
	$(CC) $(CFLAGS) $(DFLAGS) -c main.c -o main_debug.o

bezier.o: bezier.s
	nasm -f elf64 bezier.s

clean:
	rm -f *.o bezier debug *.bmp