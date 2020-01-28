PrintStatusAilment:
	ld a, [de]
	bit PSN, a
	jr nz, .psn
	bit BRN, a
	jr nz, .brn
	bit FRZ, a
	jr nz, .frz
	bit PAR, a
	jr nz, .par
	and SLP
	ret z
	ld a, $C0
	ld [hli], a
	ld a, $C1
	ld [hli], a
	ld [hl], $C2
	ret
.psn
	ld a, $C3
	ld [hli], a
	ld a, $C4
	ld [hli], a
	ld [hl], $C5
	ret
.brn
	ld a, $C6
	ld [hli], a
	ld a, $C7
	ld [hli], a
	ld [hl], $C8
	ret
.frz
	ld a, $D0
	ld [hli], a
	ld a, $D1
	ld [hli], a
	ld [hl], $D2
	ret
.par
	ld a, $D3
	ld [hli], a
	ld a, $D4
	ld [hli], a
	ld [hl], $D5
	ret
