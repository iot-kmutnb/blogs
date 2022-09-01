# use the GCC C compiler
CC=gcc
# enable compilation warning and turn on debug info
CFLAGS +=-std=gnu99 -Wall -Og -g3
# define source files (all .c files in the project directory)
SRCS = $(wildcard *.c)
# define object files
OBJ_FILES = $(SRCS:.c=.o)
# define Phony targets
.PHONY: all clean
all: main
	@echo "done..."
main: $(OBJ_FILES)
	$(CC) $(CFLAGS) $^ -o $@
%.o: %.c # use pattern rules
	$(CC) $(CFLAGS) -c $<
clean:
	rm -f *.o main
