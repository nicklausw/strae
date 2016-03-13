; gb_functions.s - a bunch of stuff for the gameboy
;
; by nicklausw
;
; do whatever with these, they're just around so you don't
; have to rewrite the basics for your projects.

include "src/gb.i"

; wait for vblank
section "wait_vblank", rom0
wait_vblank::
  ld a, [rSTAT]
  and 2 ; unimportant bytes
  jr nz, wait_vblank
  ret


; clear oam
section "clear oam", rom0
clear_oam::
  ld hl, _OAMRAM
  ld b,  _OAMRAM_LEN
  xor a

.oam_l: 
  call wait_vblank
  ldi [hl],a
  dec b
  jr nz,.oam_l ; b isn't zero
  ret


; clear screen
section "clear screen", rom0
clear_screen::
  ld hl, _SCRN0
  ld bc, SCRN_VX_B * SCRN_VY_B
    
.scr_l:
  call wait_vblank
  
  xor a
  ldi [hl],a
  
  dec c
  jr nz,.scr_l ; c isn't zero
  
  dec b
  jr nz,.scr_l ; b isn't zero
  ret



section "get_controller", rom0
get_controller::
  push bc
  push af

  ld a,P1F_5    ; get dpad
  ld [rP1],a
  ld a,[rP1]
  ld a,[rP1]    ; wait for joypad fatigue

  cpl    ; reverse bits (not necessary?)
  and $0f ; get rid of bits 4-7
  swap a    ; swap >a and <a
  ld b,a

  ld a,P1F_4    ; select P15
  ld [rP1],a

  ld a,[rP1]
  ld a,[rP1]
  ld a,[rP1]
  ld a,[rP1]
  ld a,[rP1]
  ld a,[rP1]    ; wait even more for joypad fatigue

  cpl    ; not necessary again?
  and $0f    ; see above
  or b    ; combine with b
  
  ld [controller],a ; put in ram
  
  pop af
  pop bc
  ret


section "lcd", rom0
lcd_on::
  ; enable LCDC and OBJ sprites
  push hl
  ld hl, rLCDC
  ld [hl], LCDCF_BG8000 | LCDCF_BGON | LCDCF_OBJON | LCDCF_ON ; Enable OBJ sprites and LCD controller
  pop hl
  ret

; thanks jeff frohwein of course
lcd_off::
  push af
  push hl
  ld hl,rLCDC
  ld a,[rLCDC]
  bit 7,a    ; Is LCD already off?
  ret z         ; yes, exit

  ld      a,[rIE]
  push    af
  res     0,a
  ld      [rIE],a   ; Disable vblank interrupt if enabled

.loop:  ld      a,[rLY]   ; Loop until in first part of vblank
  cp      145
  jr      nz,.loop
  
  ld a,[rLCDC]
  res     7,a    ; Turn the screen off
  ld [rLCDC],a
  
  pop     af
  ld      [rIE],a   ; Restore the state of vblank interrupt
  pop hl
  pop af
  ret

section "set_palette", rom0
set_palette::
  ld a,$80
  ld [rBCPS],a
  
  ld bc,$0869  ; b = 8, c = rBCPD

.loop1:

  di

.loop2:
  ld a,[rSTAT]
  and 2
  jr nz,.loop2

  ld a,[hl+]
  ld [c],a
  ei

  dec b
  jr nz,.loop1

  ret
