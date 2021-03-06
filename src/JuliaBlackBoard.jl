module JuliaBlackBoard

using CommonMark
using Mustache
using Base64

# for LaTeX
using Tectonic
using ImageMagick_jll
using TtH_jll


# Exports
export question
export MC, MA, TF, ESS, ORD, MAT, FIB, FIB_PLUS, FIL, NUM, SR, OP, JUMBLED_SENTENCE #, QUIZ_BOWL
export Plot, File, Tikz, LaTeX, preview, LaTeX′
export lquestion, mdquestion # tentative
export @ltx_str, @mdltx_str, @MT_str, @mt_str # reexoprt


include("mustache-additions.jl")
include("questions.jl")

end
