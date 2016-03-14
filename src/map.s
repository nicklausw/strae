; the map stuff

include "src/gb.i"


section "map", romx
map:: incbin "src/map.bin"


section "map wram", wram0
map_r: db


section "load_map", romx
load_map::
  ld de,_SCRN0
  ld bc,SCRN_X_B*SCRN_Y_B
  
.map_l:
  ld a,[hl]
  ld [de],a
  
  inc de
  
  ld a, [map_r]
  inc a
  ld [map_r],a
  
  cp SCRN_X_B
  call z,.skip_scrn
  
  inc hl
  
  dec bc
  ld a,b
  or c
  jr nz,.map_l
  
  ret


.skip_scrn:
  push hl
  
  ; put de into hl
  push de
  pop hl
  
  push bc
  
  ld bc,32-20 ; extra screen space
  add hl,bc ; hl is technically de
  
  pop bc
  
  ; put it back
  push hl
  pop de
  
  pop hl
  
  xor a
  ld [map_r],a
  ret
  