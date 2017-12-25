local tex_definefont = tex.definefont
local load_pstype1_font = require("fonts.define.pstype1")
local load_truetype_font = require("fonts.define.truetype")
local load_opentype_font = require("fonts.define.opentype")

tex_definefont("textfont", load_pstype1_font("lmr10", 10 * 65536))
tex_definefont("trajan", load_pstype1_font("trjnr10", 36 * 65536))
tex_definefont("trajanus", load_truetype_font("trajanus", 36 * 65536))
tex_definefont("cinzel", load_opentype_font("Cinzel-Regular", 36 * 65536))
tex_definefont("augustaps", load_pstype1_font("Augusta", 18 * 65536))
tex_definefont("augustatt", load_truetype_font("Augusta", 18 * 65536))
tex_definefont("alteschwabacherps", load_pstype1_font("AlteSchwabacher", 18 * 65536))
tex_definefont("alteschwabachertt", load_truetype_font("AlteSchwabacher", 18 * 65536))
tex_definefont("caslon", load_truetype_font("DSCaslonGotisch", 18 * 65536))
tex_definefont("bkfraktur", load_truetype_font("BreitkopfFraktur", 18 * 65536))
tex_definefont("durwent", load_truetype_font("Durwent", 18 * 65536))
tex_definefont("oldenglishps", load_pstype1_font("DS Old English", 18 * 65536))
tex_definefont("oldenglishtt", load_truetype_font("DS Old English", 18 * 65536))
tex_definefont("oldenglishot", load_opentype_font("DS Old English", 18 * 65536))
tex_definefont("yinit", font.define(font.read_tfm("yinit", 5 * 65536)))
tex_definefont("nginit", load_truetype_font("NeugotischeInitialen", 24 * 65536))
tex_definefont("rdvzbs", load_truetype_font("RedivivaZierbuchstaben", 24 * 65536))
tex_definefont("romantik", load_truetype_font("Romantik", 24 * 65536))
tex_definefont("ecb", load_truetype_font("EileenCaps-Black", 24 * 65536))
tex_definefont("iglesia", load_truetype_font("Iglesia", 18 * 65536))
tex_definefont("ufkzbs", load_truetype_font("UngerFrakturZierbuchstaben", 24 * 65536))

pdf.setpkresolution(600)
