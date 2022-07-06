SRC=$(wildcard *.asm)
OBJ=48

all: $(OBJ)

clean:
	rm -f *.bin *.map $(OBJ) *.o

dis: $(OBJ)
	z88dk-dis -mz80 -x $<.map -o start $< | less

$(OBJ): $(SRC)
	z88dk-z80asm -mz80 -b -m -o$@ $<
