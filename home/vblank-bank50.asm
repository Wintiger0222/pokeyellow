
; This function redraws a BG row of height 2 or a BG column of width 2.
; One of its main uses is redrawing the row or column that will be exposed upon
; scrolling the BG when the player takes a step. Redrawing only the exposed
; row or column is more efficient than redrawing the entire screen.
; However, this function is also called repeatedly to redraw the whole screen
; when necessary. It is also used in trade animation and elevator code.
RedrawRowOrColumn::
	ld a,[hRedrawRowOrColumnMode]
	and a
	ret z
	ld b,a
	xor a
	ld [hRedrawRowOrColumnMode],a
	dec b
	jr nz,.redrawRow
.redrawColumn
	ld hl,wRedrawRowOrColumnSrcTiles
	ld a,[hRedrawRowOrColumnDest]
	ld e,a
	ld a,[hRedrawRowOrColumnDest + 1]
	ld d,a
	ld c,SCREEN_HEIGHT
.loop1
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hli]
	ld [de],a
	ld a,BG_MAP_WIDTH - 1
	add e
	ld e,a
	jr nc,.noCarry
	inc d
.noCarry
; the following 4 lines wrap us from bottom to top if necessary
	ld a,d
	and a,$03
	or a,$98
	ld d,a
	dec c
	jr nz,.loop1
	xor a
	ld [hRedrawRowOrColumnMode],a
	ret
.redrawRow
	ld hl,wRedrawRowOrColumnSrcTiles
	ld a,[hRedrawRowOrColumnDest]
	ld e,a
	ld a,[hRedrawRowOrColumnDest + 1]
	ld d,a
	push de
	call .DrawHalf ; draw upper half
	pop de
	ld a,BG_MAP_WIDTH ; width of VRAM background map
	add e
	ld e,a
	; fall through and draw lower half

.DrawHalf
	ld c,SCREEN_WIDTH / 2
.loop2
	ld a,[hli]
	ld [de],a
	inc de
	ld a,[hli]
	ld [de],a
	ld a,e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and a,$1f
	ld b,a
	ld a,e
	and a,$e0
	or b
	ld e,a
	dec c
	jr nz,.loop2
	ret

; This function automatically transfers tile number data from the tile map at
; wTileMap to VRAM during V-blank. Note that it only transfers one third of the
; background per V-blank. It cycles through which third it draws.
; This transfer is turned off when walking around the map, but is turned
; on when talking to sprites, battling, using menus, etc. This is because
; the above function, RedrawRowOrColumn, is used when walking to
; improve efficiency.
AutoBgMapTransfer::
;.init
;	ld a,[hBGTransferDelay]
;	and a
;	jr z,.start
;	dec a
;	ld [hBGTransferDelay],a
;	ret
.check
	ld a,[hVEnable] ;메인화면에서 피카츄의 가장자리 색깔이 변하는 오류를 방지해 줍니다. 일단 임시로 이렇게 해 놓았는데, 나중에 오류가 생길 가능성이 농후합니다.
	bit 0,a
	ret z
.start
	ld a,[H_AUTOBGTRANSFERENABLED]
	and a
	ret z
	ld [H_SPTEMP],sp ; save stack pinter
	ld a,[H_AUTOBGTRANSFERPORTION]
	and a
	jr z,.transferTopThird
	dec a
	jr z,.transferMiddleThird
.transferBottomThird
	coord hl, 0, 12 ;C490
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(12 * 32)
	add hl,de
	xor a ; TRANSFERTOP
	jr .doTransfer
.transferTopThird
	coord hl, 0, 0 ;wTileMap
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld a,TRANSFERMIDDLE
	jr .doTransfer
.transferMiddleThird
	coord hl, 0, 6
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(6 * 32)
	add hl,de
	ld a,TRANSFERBOTTOM
.doTransfer
	;ld [H_AUTOBGTRANSFERPORTION],a ; store next portion
	ld b,6

TransferBgRows::
; unrolled loop and using pop for speed

	rept 20 / 2 - 1
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	endr

	pop de
	ld [hl], e
	inc l
	ld [hl], d

	ld a, 32 - (20 - 1)
	add l
	ld l, a
	jr nc, .ok
	inc h
.ok
	dec b
	jr nz, TransferBgRows

	ld a, [H_SPTEMP]
	ld l, a
	ld a, [H_SPTEMP + 1]
	ld h, a
	ld sp, hl
	ret

; Copies [H_VBCOPYBGNUMROWS] rows from H_VBCOPYBGSRC to H_VBCOPYBGDEST.
; If H_VBCOPYBGSRC is XX00, the transfer is disabled.
VBlankCopyBgMap::
.FlagCheck
	ld a,[hVEnable]
	bit 2,a
	jr nz,.VRAM1

	ld a,[H_VBCOPYBGSRC] ; doubles as enabling byte
	and a
	ret z
	jr .VRAM0
.VRAM1
	ld a,$2
	ld [rSVBK],a
	dec a
	ld [rVBK],a
.VRAM0	
	ld [H_SPTEMP],sp ; save stack pointer
	ld a,[H_VBCOPYBGSRC]
	ld l,a
	ld a,[H_VBCOPYBGSRC + 1]
	ld h,a
	ld sp,hl
	ld a,[H_VBCOPYBGDEST]
	ld l,a
	ld a,[H_VBCOPYBGDEST + 1]
	ld h,a
	ld a,[H_VBCOPYBGNUMROWS]
	ld b,a
	xor a
	ld [H_VBCOPYBGSRC],a ; disable transfer so it doesn't continue next V-blank
	jp TransferBgRowsVBK1
AutoBgMapTransferVBK1::
.init
	ld a,$01
	ld [rVBK],a
	inc a
	ld [rSVBK],a
.main
	ld a,[H_AUTOBGTRANSFERENABLED]
	and a
	jp z,TBR1done
	ld [H_SPTEMP],sp ; save stack pinter
	ld a,[H_AUTOBGTRANSFERPORTION]
	and a
	jr z,.transferTopThird
	dec a
	jr z,.transferMiddleThird
.transferBottomThird
	ld hl, $D8F0
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(12 * 32)
	add hl,de
	xor a ; TRANSFERTOP
	jr .doTransfer
.transferTopThird
	ld hl,$D800
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld a,TRANSFERMIDDLE
	jr .doTransfer
.transferMiddleThird
	ld hl,$D878
	ld sp,hl
	ld a,[H_AUTOBGTRANSFERDEST + 1]
	ld h,a
	ld a,[H_AUTOBGTRANSFERDEST]
	ld l,a
	ld de,(6 * 32)
	add hl,de
	ld a,TRANSFERBOTTOM
.doTransfer
	ld [H_AUTOBGTRANSFERPORTION],a ; store next portion
	ld b,6
.check
	ld a,[hVEnable] ;메인화면에서 피카츄의 가장자리 색깔이 변하는 오류를 방지해 줍니다. 일단 임시로 이렇게 해 놓았는데, 나중에 오류가 생길 가능성이 농후합니다.
	bit 1,a ;가 아니고 그냥 기존 팔레트와의 호환을 위해 만들었습니다... 제대로 된 작동은 보장하지 않아요.
	jp z, TBR1GetOriginalStack
TransferBgRowsVBK1:
; unrolled loop and using pop for speed

	rept 20 / 2 - 1
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	endr

	pop de
	ld [hl], e
	inc l
	ld [hl], d

	ld a, 32 - (20 - 1)
	add l
	ld l, a
	jr nc, .ok
	inc h
.ok
	dec b
	jr nz, TransferBgRowsVBK1
TBR1GetOriginalStack:
	ld a, [H_SPTEMP]
	ld l, a
	ld a, [H_SPTEMP + 1]
	ld h, a
	ld sp, hl
TBR1done:
	ld a,$01
	ld [rSVBK],a
	dec a
	ld [rVBK],a
	ret