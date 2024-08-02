module termcolor

pub enum FG {
	black         = 30
	red
	green
	yellow
	blue
	magenta
	cyan
	white
	default       = 39
	light_gray    = 90
	light_red
	light_green
	light_yellow
	light_blue
	light_magenta
	light_cyan
	bright_white
}

pub enum BG {
	black         = 40
	red
	green
	yellow
	blue
	magenta
	cyan
	white
	default       = 49
	light_gray    = 100
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

fn (s Style) to_styles () string {
	mut a := u16(s)
	mut c := ''
	for i := 1; i <= 10 ; i++ {
		if a % 2 == 1 {
			c = c + ';' + i.str()
		}
		a = a >> 1 
	}
	return c
}

const fg_rgb = 38
const bg_rgb = 48

const prefix = '\033['
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
	text  string @[required]
	fc    FG = .default
	bc    BG = .default
	fhex  string
	bhex  string
	r     int
	g     int
	b     int
	br    int
	bg    int
	bb    int
	fbit  int
	bbit  int
	style Style = .normal
	mode  Mode  = .col
}

pub fn colorize(text Text) string {
	mut styles := text.style.to_styles()
	
	frgb := text.fhex.u8_array()
	brgb := text.bhex.u8_array()

	match text.mode {
		.col {
			return '${termcolor.prefix}${int(text.bc)};${int(text.fc)}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
		}
		.hex {
			if text.bhex == '' {
				return '${termcolor.prefix}${termcolor.fg_rgb};2;${frgb[0]};${frgb[1]};${frgb[2]}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			} else {
				return '${termcolor.prefix}${termcolor.bg_rgb};2;${brgb[0]};${brgb[1]};${brgb[2]};${termcolor.fg_rgb};2;${frgb[0]};${frgb[1]};${frgb[2]}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			}
		}
		.rgb {
			if text.br == 0 || text.bg == 0 || text.bb == 0 {
				return '${termcolor.prefix}${termcolor.fg_rgb};2;${text.r};${text.g};${text.b}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			} else {
				return '${termcolor.prefix}${termcolor.bg_rgb};2;${text.br};${text.bg};${text.bb};${termcolor.fg_rgb};2;${text.r};${text.g};${text.b}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			}
		}
		.bit {
			if text.bbit == 0 {
				return '${termcolor.prefix}38;5;${text.fbit}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			} else {
				return '${termcolor.prefix}48;5;${text.bbit};38;5;${text.fbit}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
			}
		}
		else {
			return '${termcolor.prefix}${int(FG.default)}${styles}${termcolor.suffix}${text.text}${termcolor.reset}'
		}
	}
}
