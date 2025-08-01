; -----------------------------------------------------------------------------
; RCS-CPC buffered decoder optimized by Madram
; RCS-CPC decoder from buffer at 0x4000 to regular screen at 0x8000
; -----------------------------------------------------------------------------
; Parameters:
; DE: source buffer address (RCS data) - Currently must be 0x4000
; HL: destination screen address - Currently must be 0x8000
; -----------------------------------------------------------------------------

; Value of CRTC R1 (80 for default screen size)
r1	equ 80

drcs_buffered_rapid:
		PUSH HL

drcs_next_row:
		; Copy one byte and increment HL
		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		; This relies on HL = 8000 as bit 6 detects overflow into C000 space
		; Adjust depending on desired value of HL:
		; HL = 0000 or 8000: use bit 6 and JR Z
		; HL = 4000 or C000: use bit 6 and JR NZ
		BIT 6, a
		JR Z, drcs_next_row

		LD BC, &C000 + r1 * 2
		ADD HL,BC

		BIT 3,H
		JR Z, okcol

		POP HL
		INC HL
		PUSH HL

okcol
		; This relies on DE being 0x4000. ADD A will detect overflow into 8000 space.
		LD A,D
		ADD A
		JR NC, drcs_next_row

		POP HL
		RET
