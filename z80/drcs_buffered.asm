; -----------------------------------------------------------------------------
; RCS-CPC buffered decoder by PulkoMandy
; RCS-CPC decoder from buffer at 0x4000 to regular screen at 0xC000
; -----------------------------------------------------------------------------
; Parameters:
; BC: screen width in bytes (0x80 for standard resolution)
; DE: source buffer address (RCS data) - Currently must be 0x4000
; HL: destination screen address - Currently must be 0xC000
; -----------------------------------------------------------------------------

; Correspondance with BASIC listing in README:
; I -- DE
; J -- HL
; K -- IX
; L -- IY
; WIDTH -- BC

drcs_buffered_rapid:
		PUSH HL
		PUSH HL
		POP IY
		POP IX

drcs_next_row:
		; Copy one byte and increment HL
		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		JR NC, drcs_next_row ; Use of NC here requires that HL=C000 at start of routine.

		ADD IX,BC
		PUSH IX
		POP HL

		LD A,H
		AND 0x38
		JR Z, nok

		INC IY
		PUSH IY
		PUSH IY
		POP IX
		POP HL

nok

		LD A,D
		AND 0x80 ; Valid for DE=4000, won't work for other values
		JR Z, drcs_next_row

		RET
