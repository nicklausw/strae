; lots of definitions from here
include "src/gb.i"


; ram
section "ram", wram0
sprite_table: ds 4*60
controller:: db


; graphics
bgr: macro
  dw (\1<<10)|(\2<<5)|\3
  endm

section "gfx", romx
gfx: incbin "src/gfx.2bpp"
end_gfx:

palette:
  bgr 0, 0, 0
  bgr 0, 0, 0
  bgr 0, 31, 0
  bgr 31, 31, 31
   
; a bunch of empty vectors, why not?

section "vbi", rom0[$40]
  jp vblank_routine

section "lcd", rom0[$48]
  reti

section "timer", rom0[$50]
  reti

section "serial", rom0[$58]
  reti

section "htl", rom0[$60]
  reti


section "vblank routine", rom0
vblank_routine:
  ; if only the gameboy had
  ; exx and ex af,'af...
  push af
  push de
  push bc
  push hl
  
  call get_controller
  
  pop hl
  pop bc
  pop de
  pop af
  reti
  
  
; the first code run by the gameboy
section "entrance", rom0[$100]
  nop ; for clean code
  jp setup


; this space for rgbfix
section "reserved", rom0[$104]
  ds $150-$104


; now the real stuff
section "setup", rom0[$150]
setup:
  di ; no interrupts
  ld sp, $fffe ; set up stack
  
  cp $11
  jp nz,no_gbc
  
  ; no sound, no power consumption
  xor a
  ld [$ff26],a
  
  ; the ram could have stuff in it.
  ; so let's clear it all out
  
  ld hl,_RAM ; ram location $c000

.ram_l: xor a ; ld a,0
  ldi [hl],a ; load ram location with 0
  ; note, ldi means "load and increment hl"
  
  ; now check for $dfff
  ld a,h
  cp $df
  jr nz,.ram_l
  
  ld a,l
  cp $ff
  jr nz,.ram_l
  
  
  ; for safety
  call wait_vblank
  
  
  call lcd_off

  
  call clear_oam
  call clear_screen
    
  ; load the gfx
  ld hl, _VRAM
  ld bc,end_gfx-gfx
  ld de,gfx
  
.gfx_l: call wait_vblank
  ld a,[de] ; get byte
  ldi [hl],a ; store byte
  inc de ; next byte
  
  dec bc
  ld a,c
  or b
  jr nz,.gfx_l ; bc isn't zero
  
  ; now the palette
  ld hl,palette
  call set_palette
  
  ld hl,_SCRN0
  ld a,1
  ld [hl],a
  
  call lcd_on

  ld a, IEF_VBLANK
  ld [rIE],a ; vblanks on
  
  ei
  
.end: halt
  jr .end


section "no_gbc", rom0
no_gbc: ; do nothing
  jr no_gbc
