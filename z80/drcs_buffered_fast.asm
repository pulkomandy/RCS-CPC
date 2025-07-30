; -----------------------------------------------------------------------------
; RCS-CPC buffered decoder by Madram - Fast version with unrolled loop
; RCS-CPC decoder from buffer at 0x4000 to regular screen
; -----------------------------------------------------------------------------
; Parameters:
; DE: source buffer address (RCS data) - Currently must be 0x4000
; HL: destination screen address
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

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

		ld a,8
		add h
		ld h,a

		ld      a, (de)
		inc     de
		ld      (hl), a

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
