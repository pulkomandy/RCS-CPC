; -----------------------------------------------------------------------------
; RCS-CPC buffered decoder by Millihertz (33 bytes)
; RCS-CPC decoder from buffer at 0x4000 to regular screen at 0xC000
; -----------------------------------------------------------------------------
; Parameters:
; HL: source buffer address (RCS data)
; DE: destination screen address - Currently must be 0xC000
; -----------------------------------------------------------------------------

SCREEN_WIDTH equ 112

drcs_buffered_rapid:
		LD IXl,SCREEN_WIDTH

_next_stripe:
		push hl

_next_block:
		; "fast" version: LD BC,0x7ff here
_next_row:
		ex de,hl
		ldi		; *hl++ = *de++, bc--
		ex de,hl
		ld bc, 0x7ff
		; "fast" version: INC BC here instead of the ld bc above
		add hl,bc
		jr nc,_next_row ; Use of NC here makes this only work for C000-FFFF as a target

		ld bc, 0xC000 + SCREEN_WIDTH
		add hl, bc
		ld a,h
		cp 0xc8
		jr c,_next_block

		pop hl
		inc hl
		dec IXl
		jr nz, _next_stripe

		RET
