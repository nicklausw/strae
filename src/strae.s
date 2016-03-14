; lots of definitions from here
include "src/gb.i"


; defines
jump_up = 1
jump_down = 2
jump_height = 20


; ram
section "ram", wram0
player_y: db
player_x: db
player_tile: db
controller:: db
jump: db
jump_l: db


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
  
  call get_controller

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
  ld [rNR52],a
  
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
  
  ld hl,palette
  call set_obj_palette
  
  ld a,1
  ld [player_tile],a
  
  ld a,8*10
  ld [player_x],a
  ld [player_y],a
  
  ld hl,map
  call load_map
  
  call lcd_on

  ld a, IEF_VBLANK
  ld [rIE],a ; vblanks on
  
  ei
  
  jp move_func


section "move_func", rom0
move_func:
  halt
  call copy_sprite
  
  ld a,[jump]
  inc a
  cp 1
  jr z,.not_jumping
  
  call handle_a
  jr .yes_jumping
  
.not_jumping:
  ld a,[controller]
  bit PADB_A,a
  call nz,set_jump
  

.yes_jumping:
  ld a,[controller]
  bit PADB_LEFT,a
  jr nz,.no_left
  
  ld a,[player_x]
  inc a
  ld [player_x],a
  
.no_left:
  ld a,[controller]
  bit PADB_RIGHT,a
  jr nz,.no_right
  
  ld a,[player_x]
  dec a
  ld [player_x],a

.no_right:
  jr move_func


section "copy_sprite", rom0
copy_sprite:
  ld hl,_OAMRAM
  ld de,player_y
  ld b,3
  
.cs_l:
  call wait_vblank
  ld a,[de]
  ldi [hl],a
  inc de
  dec b
  jr nz,.cs_l
  
  ret


section "set_jump", rom0
set_jump:
  ld a,jump_up
  ld [jump],a
  
  xor a
  ld [jump_l],a
  
  ret


section "handle_a", rom0
handle_a:
  ld a,[jump]
  cp jump_up
  jp z,.handle_up
  
  ld a,[jump]
  cp jump_down
  jp z,.handle_down

  
.handle_up:
  ld a,[jump_l]
  inc a
  cp jump_height
  jr z,.up_done
  
  ld [jump_l],a
  
  ld a,[player_y]
  dec a
  ld [player_y],a
  
  ret
  
  
.up_done:
  ld [jump_l],a
  
  ld a,jump_down
  ld [jump],a
  ret

  
.handle_down:
  ld a,[jump_l]
  dec a
  jr z,.down_done
  
  ld [jump_l],a
  
  ld a,[player_y]
  inc a
  ld [player_y],a
  
  ret
  
.down_done:
  xor a
  ld [jump],a
  ld [jump_l],a
  ret


section "no_gbc", rom0
no_gbc: ; do nothing
  jr no_gbc
