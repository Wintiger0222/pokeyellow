LCDC::
	push af
	ld a,[rSVBK]
	ld [H_LOADEDWRAMBANK],a
	ld a,$01
	ld [rSVBK],a
	ld a, [hLCDCPointer] ; doubles as enabling byte
	and a
	jr z, .noLCDCInterrupt
	push hl
	; [C700 + [rLY]] --> [FF00 + [hLCDCPointer]]
	ld a, [rLY]
	ld l, a
	ld h, wLYOverrides / $100
	ld h, [hl] ; h != not part of pointer
	ld a, [hLCDCPointer]
	ld l, a
	ld a, h
	ld h, $ff
	ld [hl], a
	pop hl
.noLCDCInterrupt
	ld a,[H_LOADEDWRAMBANK]
	ld [rSVBK],a
	pop af
	reti
