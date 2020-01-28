CopyDataWRAM2::
	ld [hTemp],a ;메모리 뱅크 변경할때에는 push와 같은 스택 명령어 사용 금지.
	ld a,$02
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
	ld a,[hTemp]
	call CopyData
	ld [hTemp],a ;메모리 뱅크 변경할때에는 push와 같은 스택 명령어 사용 금지.
	ld a,$01
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
	ld a,[hTemp]
	ret
_SaveScreenTilesToBuffer2::
	coord hl, 0, 0
	ld de, wTileMapBackup2
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
	ld hl,$D800
	ld de, $DC00
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyDataWRAM2
	ret
_LoadScreenTilesFromBuffer2::
	call LoadScreenTilesFromBuffer2DisableBGTransfer
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ret

; loads screen tiles stored in wTileMapBackup2 but leaves H_AUTOBGTRANSFERENABLED disabled
_LoadScreenTilesFromBuffer2DisableBGTransfer::
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld hl, wTileMapBackup2
	coord de, 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
	ld hl, $DC00
	ld de, $D800
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyDataWRAM2
	ret

_SaveScreenTilesToBuffer1::
	coord hl, 0, 0
	ld de, wTileMapBackup
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
	ld hl, $D800
	ld de, $DA00
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyDataWRAM2
	ret
_LoadScreenTilesFromBuffer1OnlyVBK0::
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld hl, wTileMapBackup
	coord de, 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ret
_LoadScreenTilesFromBuffer1::
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a
	ld hl, wTileMapBackup
	coord de, 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
	ld hl, $DA00
	ld de, $D800
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyDataWRAM2
	ld a, 1
	ld [H_AUTOBGTRANSFERENABLED], a
	ret
_ClearScreenArea::
	ld a,[H_AUTOBGTRANSFERENABLED]
	push af
	xor a
	ld [H_AUTOBGTRANSFERENABLED],a
	ld a,[H_2TEMP]
	ld h,a
	ld a,[H_2TEMP+1]
	ld l,a
	ld a,[hTemp]
	ld b,a
	push hl
	push bc
	call ClearScreenAreaVRAM0
	pop bc
	pop hl
	call ClearScreenAreaVRAM1
	pop af
	ld [H_AUTOBGTRANSFERENABLED],a
	ret
ClearScreenAreaVRAM0::
; Clear tilemap area cxb at hl.
	ld a, " " ; blank tile
	ld de, 20 ; screen width
.y
	push hl
	push bc
.x
	ld [hli], a
	dec c
	jr nz, .x
	pop bc
	pop hl
	add hl, de
	dec b
	jr nz, .y
	ret
ClearScreenAreaVRAM1::
; Clear tilemap area cxb at hl.
	ld de, 20 ; screen width
	push bc
	ld bc,$1460
	add hl,bc
	pop bc
	ld a,$02
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
.y
	push hl
	push bc
.x
	res 3,[hl]
	inc hl
	dec c
	jr nz, .x
	pop bc
	pop hl
	add hl, de
	dec b
	jr nz, .y
	ld a,$01
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
	ret
_LegacyClearScreen::
; Clear wTileMap, then wait
; for the bg map to update.

	ld bc, 20 * 18
	inc b
	coord hl, 0, 0
	ld a, " "
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	jp Delay3
_ClearScreen::
; Clear wTileMap, then wait
; for the bg map to update.

	ld bc, 20 * 18
	inc b
	coord hl, 0, 0
	ld a, " "
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	;jp Delay3
_ClearScreenVBK1::
	;HangulSupport
	ld a,$02
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
	ld bc, 20 * 18
	inc b
	ld hl,$D800
.loop2
	res 3, [hl]
	inc hl
	dec c
	jr nz, .loop2
	dec b
	jr nz, .loop2
	ld a,$01
	;di
	;ld [H_LOADEDWRAMBANK],a
	ld [rSVBK],a
	;ei
	jp Delay3
CheckHash::
	ld b,$00
	ld c,31
	ld hl,Hash
.loop
	ld a,[hli]
	xor b
	ld b,a
	dec c
	jr nz,.loop
	ld hl,Hash+31
	ld a,[hl]
	cp b
	ret z
.stoploop
	stop
	jr .stoploop
Hash::
	db $52,$45,$50,$41,$49,$52,$1F,$7A,$24,$02,$8A,$89,$45,$18,$57,$D4,$A4,$D5,$BC,$38,$53,$80,$88,$4F,$C7,$F8,$EC,$AE,$87,$A3,$D0,$EB ;REPAIR

	;유출방지용 해쉬
	