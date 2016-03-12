CC = rgbasm
LD = rgblink
FIX = rgbfix

OUT = strae.gbc
SYM = strae.sym

EMU = wine ~/dev/gb/bgb/bgb.exe

SFILES = $(wildcard src/*.s)
OFILES = $(subst .s,.o,$(SFILES))

$(OUT): $(OFILES)
	$(LD) -t -n $(SYM) -o $(OUT) $(OFILES)
	$(FIX) -v -c -t "STRAE" $(OUT)
	$(EMU) $(OUT) >/dev/null 2>&1

src/%.o: src/%.s $(MUSIC_O)
	$(CC) -o $@ $<
	
clean:
	rm -f $(OFILES) $(OUT) $(SYM)

