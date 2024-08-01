module termcolor

import math.bits

pub enum FG {
	black = 30
	red
	green
	yellow
	blue
	magenta
	cyan
	white 
	default = 39
	light_gray = 90 
	light_red
	light_green 
	light_yellow 
	light_blue 
	light_magenta 
	light_cyan 
	bright_white 
}

pub enum BG {
	black = 40
	red
	green
	yellow
	blue
	magenta
	cyan
	white 
	default = 49
	light_gray = 100 
	light_red
	light_green 
	light_yellow 
	light_blue 
	light_magenta 
	light_cyan 
	bright_white 
}

@[flag]
pub enum Style {
	bold 
	dim
	italic
	underline
	blink
	rapid
	reverse
	hidden
	crossed
	normal 
}

const fg_rgb = 38
const bg_rgb = 48

const prefix = '\e['
const suffix = 'm'
const reset = '${prefix}0${suffix}'

pub enum Mode {
	col
	rgb
	hex
	bit
	@none
}

@[params]
pub struct Text {
pub:
	text string @[required]
	fc FG = .default
	bc BG = .default
	fhex string
	bhex string
	r int
	g int
	b int
	br int
	bg int
	bb int
	fbit int
	bbit int
	style Style = .normal
	mode Mode = .col
}

pub fn colorize(text Text) string {

	mut styles := ''
	for i in [Style.bold, .dim, .italic, .underline, .blink, .rapid, .reverse, .hidden, .crossed, .normal] {
		if text.style.has(i) {
			styles = styles + ';' + (bits.trailing_zeros_16(u16(i)) + 1).str()
		}
	}

	frgb := text.fhex.u8_array()
	brgb := text.bhex.u8_array()

	match text.mode {
		.col {
    		return '${prefix}${int(text.bc)};${int(text.fc)}${styles}${suffix}${text.text}${reset}'
		}
		.hex {
			if text.bhex == '' {
				return '${prefix}${fg_rgb};2;${frgb[0]};${frgb[1]};${frgb[2]}${styles}${suffix}${text.text}${reset}'
			}else {
				return '${prefix}${bg_rgb};2;${brgb[0]};${brgb[1]};${brgb[2]};${fg_rgb};2;${frgb[0]};${frgb[1]};${frgb[2]}${styles}${suffix}${text.text}${reset}'
			}
		}
		.rgb {
			if text.br == 0 || text.bg == 0 || text.bb == 0 {
				return '${prefix}${fg_rgb};2;${text.r};${text.g};${text.b}${styles}${suffix}${text.text}${reset}'
			}else {
				return '${prefix}${bg_rgb};2;${text.br};${text.bg};${text.bb};${fg_rgb};2;${text.r};${text.g};${text.b}${styles}${suffix}${text.text}${reset}'
			}
		}
		.bit {
			if text.bbit == 0 {
				return '${prefix}38;5;${text.fbit}${styles}${suffix}${text.text}${reset}'
			}else {
				return '${prefix}48;5;${text.bbit};38;5;${text.fbit}${styles}${suffix}${text.text}${reset}'
			}
		}
		else {
    		return '${prefix}${int(FG.default)}${styles}${suffix}${text.text}${reset}'
		}
	}
}