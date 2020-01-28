DisplayOptionMenu_:
	call Func_41f06
.optionMenuLoop
	call JoypadLowSensitivity
	ld a, [hJoy5]
	and START | B_BUTTON
	jr nz, .exitOptionMenu
	call Func_41eb7
	jr c, .asm_41c86
	call Func_41c95
	jr c, .exitOptionMenu
.asm_41c86
	call Func_41ee9
	call DelayFrame
	call DelayFrame
	call DelayFrame
	jr .optionMenuLoop
.exitOptionMenu
	ret

Func_41c95:
	ld a, [wOptionsCursorLocation]
	ld e, a
	ld d, $0
	ld hl, OptionMenuJumpTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

OptionMenuJumpTable:
	dw OptionsMenu_TextSpeed
	dw OptionsMenu_BattleAnimations
	dw OptionsMenu_BattleStyle
	dw OptionsMenu_SpeakerSettings
	dw OptionsMenu_Dummy
	dw OptionsMenu_Dummy
	dw OptionsMenu_Dummy
	dw OptionsMenu_Cancel

OptionsMenu_TextSpeed:
	call Func_41d07
	ld a, [hJoy5]
	bit 4, a ; right
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .asm_41ce0
.pressedRight
	ld a, c
	cp $2
	jr c, .asm_41cca
	ld c, $ff
.asm_41cca
	inc c
	ld a, e
	jr .asm_41cd6
.pressedLeft
	ld a, c
	and a
	jr nz, .asm_41cd4
	ld c, $3
.asm_41cd4
	dec c
	ld a, d
.asm_41cd6
	ld b, a
	ld a, [wOptions]
	and $f0
	or b
	ld [wOptions], a
.asm_41ce0
	ld b, $0
	ld hl, TextSpeedStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 11, 2
	call PlaceString
	and a
	ret

TextSpeedStringsPointerTable:
	dw FastText
	dw MidText
	dw SlowText

FastText:
	db $05,$6C,$04,$33,$01,$34,$50
MidText:
	db $05,$18,$09,$BB,$0B,$6D,$50
SlowText:
	db $02,$C0,$04,$3E,$01,$34,$50

Func_41d07:
	ld a, [wOptions]
	and $f
	cp $5
	jr z, .slowTextOption
	cp $1
	jr z, .fastTextOption
; mid text option
	ld c, $1
	lb de, 1, 5
	ret
.slowTextOption
	ld c, $2
	lb de, 3, 1
	ret
.fastTextOption
	ld c, $0
	lb de, 5, 3
	ret

OptionsMenu_BattleAnimations:
	ld a, [hJoy5]
	and D_RIGHT | D_LEFT
	jr nz, .asm_41d33
	ld a, [wOptions]
	and $80 ; mask other bits
	jr .asm_41d3b
.asm_41d33
	ld a, [wOptions]
	xor $80
	ld [wOptions], a
.asm_41d3b
	ld bc, $0
	sla a
	rl c
	ld hl, AnimationOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 11, 4
	call PlaceString
	and a
	ret

AnimationOptionStringsPointerTable:
	dw AnimationOnText
	dw AnimationOffText

AnimationOnText:
	db $05,$18,$02,$D9,$0B,$6D,$0B,$6D,$50
AnimationOffText:
	db $06,$C8,$0B,$6D,$05,$18,$02,$D9,$50

OptionsMenu_BattleStyle:
	ld a, [hJoy5]
	and D_LEFT | D_RIGHT
	jr nz, .asm_41d6b
	ld a, [wOptions]
	and $40 ; mask other bits
	jr .asm_41d73
.asm_41d6b
	ld a, [wOptions]
	xor $40
	ld [wOptions], a
.asm_41d73
	ld bc, $0
	sla a
	sla a
	rl c
	ld hl, BattleStyleOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 11, 6
	call PlaceString
	and a
	ret

BattleStyleOptionStringsPointerTable:
	dw BattleStyleShiftText
	dw BattleStyleSetText

BattleStyleShiftText:
	db $01,$83,$08,$BC,$0B,$6D,$09,$88,$07,$A4,$0B,$6D,$0B,$6D,$0B,$6D,$50
BattleStyleSetText:
	db $06,$62,$07,$AA,$0B,$6D,$01,$48,$06,$03,$0B,$6D,$09,$88,$07,$A4,$50

OptionsMenu_SpeakerSettings:
	ld a, [wOptions]
	and $30
	swap a
	ld c, a
	ld a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .asm_41dca
.pressedRight
	ld a, c
	inc a
	and $3
	jr .asm_41dba
.pressedLeft
	ld a, c
	dec a
	and $3
.asm_41dba
	ld c, a
	swap a
	ld b, a
	xor a
	ld [rNR51], a
	ld a, [wOptions]
	and $cf
	or b
	ld [wOptions], a
.asm_41dca
	ld b, $0
	ld hl, SpeakerOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 11, 8
	call PlaceString
	and a
	ret

SpeakerOptionStringsPointerTable:
	dw MonoSoundText
	dw Earphone1SoundText
	dw Earphone2SoundText
	dw Earphone3SoundText

MonoSoundText:
	db $04,$90,$02,$8B,$0B,$6D,$7F,$50
Earphone1SoundText:
	db $0A,$8C,$03,$45,$0A,$29,$F7,$50
Earphone2SoundText:
	db $0A,$8C,$03,$45,$0A,$29,$F8,$50
Earphone3SoundText:
	db $0A,$8C,$03,$45,$0A,$29,$F9,$50

OptionsMenu_GBPrinterBrightness:
	call Func_41e7b
	ld a, [hJoy5]
	bit 4, a
	jr nz, .pressedRight
	bit 5, a
	jr nz, .pressedLeft
	jr .asm_41e32
.pressedRight
	ld a, c
	cp $4
	jr c, .asm_41e22
	ld c, $ff
.asm_41e22
	inc c
	ld a, e
	jr .asm_41e2e
.pressedLeft
	ld a, c
	and a
	jr nz, .asm_41e2c
	ld c, $5
.asm_41e2c
	dec c
	ld a, d
.asm_41e2e
	ld b, a
	ld [wPrinterSettings], a
.asm_41e32
	ld b, $0
	ld hl, GBPrinterOptionStringsPointerTable
	add hl, bc
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	coord hl, 11, 10
	call PlaceString
	and a
	ret

GBPrinterOptionStringsPointerTable:
	dw LightestPrintText
	dw LighterPrintText
	dw NormalPrintText
	dw DarkerPrintText
	dw DarkestPrintText

LightestPrintText:
	db $01,$01,$07,$B5,$0B,$6D,$04,$E0,$01,$34,$0B,$6D,$50
LighterPrintText:
	db $04,$E0,$01,$34,$0B,$6D,$0B,$6D,$0B,$6D,$0B,$6D,$50
NormalPrintText:
	db $05,$18,$09,$BB,$0B,$6D,$0B,$6D,$0B,$6D,$0B,$6D,$50
DarkerPrintText:
	db $06,$EE,$03,$33,$01,$34,$0B,$6D,$0B,$6D,$0B,$6D,$50
DarkestPrintText:
	db $01,$01,$07,$B5,$0B,$6D,$06,$EE,$03,$33,$01,$34,$50

Func_41e7b:
	ld a, [wPrinterSettings]
	and a
	jr z, .asm_41e93
	cp $20
	jr z, .asm_41e99
	cp $60
	jr z, .asm_41e9f
	cp $7f
	jr z, .asm_41ea5
	ld c, $2
	lb de, $20, $60
	ret
.asm_41e93
	ld c, $0
	lb de, $7f, $20
	ret
.asm_41e99
	ld c, $1
	lb de, $0, $40
	ret
.asm_41e9f
	ld c, $3
	lb de, $40, $7f
	ret
.asm_41ea5
	ld c, $4
	lb de, $60, $0
	ret

OptionsMenu_Dummy:
	and a
	ret

OptionsMenu_Cancel:
	ld a, [hJoy5]
	and A_BUTTON
	jr nz, .pressedCancel
	and a
	ret
.pressedCancel
	scf
	ret

Func_41eb7:
	ld hl, wOptionsCursorLocation
	ld a, [hJoy5]
	cp D_DOWN
	jr z, .pressedDown
	cp D_UP
	jr z, .pressedUp
	and a
	ret
.pressedDown
	ld a, [hl]
	cp $7
	jr nz, .doNotWrapAround
	ld [hl], $0
	scf
	ret
.doNotWrapAround
	cp $3
	jr c, .regularIncrement
	ld [hl], $6
.regularIncrement
	inc [hl]
	scf
	ret
.pressedUp
	ld a, [hl]
	cp $7
	jr nz, .doNotMoveCursorToPrintOption
	ld [hl], $3
	scf
	ret
.doNotMoveCursorToPrintOption
	and a
	jr nz, .regularDecrement
	ld [hl], $8
.regularDecrement
	dec [hl]
	scf
	ret

Func_41ee9:
	coord hl, 1, 1
	ld de, SCREEN_WIDTH
	ld c, 16
.loop
	ld [hl], " "
	add hl, de
	dec c
	jr nz, .loop
	coord hl, 1, 2
	ld bc, SCREEN_WIDTH * 2
	ld a, [wOptionsCursorLocation]
	call AddNTimes
	ld [hl], "▶"
	ret

Func_41f06:
	coord hl, 0, 0
	lb bc, SCREEN_HEIGHT - 2, SCREEN_WIDTH - 2
	call TextBoxBorder
	coord hl, 2, 2
	ld de, AllOptionsText
	call PlaceString
	coord hl, 2, 16
	ld de, OptionMenuCancelText
	call PlaceString
	xor a
	ld [wOptionsCursorLocation], a
	ld c, 5
.loop
	push bc
	call Func_41c95
	pop bc
	ld hl, wOptionsCursorLocation
	inc [hl]
	dec c
	jr nz, .loop
	xor a
	ld [wOptionsCursorLocation], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	call Delay3
	ret

AllOptionsText:
	db $07,$9C,$06,$DF,$01,$B2,$07,$97,$7F,$06,$03,$03,$15
	next $07,$CC,$09,$C5,$7F,$06,$D6,$02,$CF,$04,$7E,$07,$9C,$05,$F7
	next $06,$63,$0A,$75,$07,$97,$7F,$04,$1A
	next $05,$B7,$07,$4E,$03,$45,"@"

OptionMenuCancelText:
	db $02,$31,$50,$0A,$71,$01,$AB,$0A,$AD,$0B,$68,$96,$A8,$AD,$A3,$AE,$B6,$B2,$93,$A8,$A6,$A4,$B1,$F3,$02,$9A,$06,$BE

