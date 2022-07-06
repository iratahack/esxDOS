SRC=$(wildcard *.c)
OBJ=info

all: $(OBJ)

clean:
	rm -f *.bin *.map $(OBJ)

dis: $(OBJ)
	z88dk-dis -mz80 -x $<.map -o CRT_ORG_CODE $< | less

$(OBJ): $(SRC)
	zcc +zx $< -m -o$@ -lesxdos -zorg 8192
