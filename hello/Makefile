SRC=$(wildcard *.c)
OBJ=hello

all: $(OBJ)

clean:
	rm -f *.bin *.map $(OBJ)

dis: $(OBJ)
	z88dk-dis -mz80 -x $<.map -o CRT_ORG_CODE $< | less

hello: $(SRC)
	zcc +zx $< -m -o$@ -lesxdos -zorg 8192
