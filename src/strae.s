; lots of definitions from here
include "src/gb.i"


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
section "setup", rom0
setup:
  di ; no interrupts
  ld sp, $fffe ; set up stack
  
  
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
    
  
  call lcd_on

  ld a, IEF_VBLANK
  ld [rIE],a ; vblanks on
  
  ei
.end: jr .end
