GBCOnlyScreen2: ; 4ea82

	ld a, [hGBC]
	and a
	ret nz
	
	;ld hl, GBCOnlyGFX
	;ld de, $d000
	;call CopyVideoData
	;coord hl, 2, 7
	;ld de, CopyrightTextString
	;jp PlaceString
	;시발 어떻게 짜야되지
	
	
.loop
	call DelayFrame
	jr .loop
	
