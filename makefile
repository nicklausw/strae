CC = rgbasm
LD = rgblink
FIX = rgbfix

OUT = strae.gb
SYM = strae.sym

EMU = gambatte_qt

SFILES = $(wildcard src/*.s)
OFILES = $(subst .s,.o,$(SFILES))

all: $(OUT)
	$(EMU) $(OUT) >/dev/null 2>&1

$(OUT): $(OFILES)
	$(LD) -n $(SYM) -o $(OUT) $(OFILES)
	$(FIX) -v -k FF -t "STRAE" $(OUT)

src/%.o: src/%.s $(MUSIC_O)
	$(CC) -o $@ $<
	
clean:
	rm -f $(OFILES) $(OUT) $(SYM)

