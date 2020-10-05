## Modification to Mustache and friends to make this easier to work with

## Image substitution: LaTeX, Plot, File
## in Markdown ![alt](url) will display a graphic image by url
## We use mustache and a few files to add other images:
## The pattern: ![alt]({{{:img}}}) can hold
## * a Plots plot, `p`, when `img=Plot(p)`
## * a local file when `img=File(file_name)`.
## * LaTeX includes the ![alt](...) in it
## For each, the image is embedded as a Base64-encode string

# Plots. Workflow
# template include: ![Alt]({{{:figure}}})
# use `figure=Plot(p)` in ther context
# Also File(fname) and LaTeX(snippet) produce figures
function Plot(p)
    io  = IOBuffer()
    show(io, MIME("image/png"), p)
    data = Base64.base64encode(take!(io))
    close(io)

    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,data)
    String(take!(io))
end


## File ![alt]({{{:img}}})
## where `img = File("imagefile.png"))` is in context
function File(p)
    img = base64encode(read(p, String))
    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,img)
    String(take!(io))
end

## Templates

# used to include LaTeX into MarkDown
const LaTeX_tpl = mt"""![{{{:alt}}}]({{{:latex}}})"""

# used by tth
const tth_tpl = mt"""
\documentclass{article}
\usepackage{amssymb}
\usepackage{amsmath}
{{#:pkgs}}
\usepackage{ {{.}} }
{{/:pkgs}}

\begin{document}
\thispagestyle{empty}
{{{:txt}}}
\end{document}
"""

# use by LaTeX and preview to create pdf
# uses preview package to frame output
const preview_tpl = mt"""
\documentclass{article}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{float}
\usepackage{tikz}
{{#:pkgs}}
\usepackage{ {{.}} }
{{/:pkgs}}

\usepackage[active, tightpage]{preview}
\setlength\PreviewBorder{10pt}%

\begin{document}
\thispagestyle{empty}
\begin{preview}
\{{:fontsize}}
{{{:txt}}}
\end{preview}
\end{document}
"""

## LaTeX to [HTML, png]
# convert latex to png file
latex_to_png(str::Mustache.MustacheTokens;kwargs...) = latex_to_png(str(); kwargs...)
function latex_to_png(str;  fontsize="LARGE", tpl=preview_tpl, pkgs=[])

    fnm = tempname()
    fnmtex = fnm * ".tex"
    fnmpdf = fnm * ".pdf"
    fnmpng = fnm * ".png"
    
    open(fnmtex, "w") do io
        Mustache.render(io, tpl, (txt=str, fontsize=fontsize, pkgs=collect(pkgs)))
    end
    tectonic() do bin
        run(`$bin -c minimal $fnmtex`)
    end

    run(`cp $fnmtex /tmp/test.tex`)

    if Sys.isapple()
        run(pipeline(`sips -s format png $fnmpdf --out $fnmpng`, stdout=devnull))
    else
        imagemagick_convert() do bin
            run(`$bin -density 150 -depth 8 -quality 100 $fnmpdf $fnmpng`)
        end
    end

    return fnmpng

    # Keep in case useful elsewhere; no longer used as with preview no need to trim
    # hack to trim pdf and write out png
    # function _findfirst(rs)
    #     i = findfirst(iszero, rs)
    #     i == nothing ? 1 : i
    # end
    # function _findlast(rs)
    #     i = findlast(iszero, rs)
    #     i == nothing ? length(rs) : i
    # end
    # WHITE = ImageMagick.RGBA{ImageMagick.N0f16}(1.0,1.0,1.0,0.0)
    # rs = [all(a[i,:] .== WHITE) for i in 1:size(a, 1)]
    # cs = [all(a[:,j] .== WHITE) for j in 1:size(a, 2)]
    # rₘ = _findfirst(rs)
    # rₙ = _findlast(rs)
    # cₘ = _findfirst(cs)
    # cₙ = _findlast(cs)
    # b = a[rₘ:rₙ, cₘ:cₙ]
    # save(fnmpng, b, quality=100)
    # return fnmpng
    
end


const FONTSIZE = "large"

"""
    LaTeX(str; alt="", tpl=[preview_tpl], fontsize="$FONTSIZE", pkgs=[])

Run LaTeX and produce output for inclusion as a question. 

Returns string for a Markdown figure, e.g,
`"![alt](latex_as_encoded_png_file)"` that gets rendered into an image.

* `alt`: alt tag for the image

* `tpl`: what template to use, default uses `preview` package.

* `fontsize`: what fontsize to use, among ( "Huge", "huge", "LARGE", "Large", "large", 
"normalsize", "small", "footnotesize", "scriptsize", "tiny)

* `pkgs` a collection of package names for inclusion through `\\usepackage{pkgname}`

To get a png file from a LaTeX snippet, `str`, we have

```
JuliaBlackBoard.latex_to_png(str)
```


"""
function LaTeX(str;
               alt = "",
               tpl=preview_tpl,
               fontsize=FONTSIZE,
               pkgs=[])

    fnm = latex_to_png(str, fontsize=fontsize, tpl=tpl, pkgs=pkgs)
    LaTeX_tpl(latex=File(fnm), alt=create_html(alt, strip=true))
    
end



# show the png file generated
preview(mt::Mustache.MustacheTokens; kwargs...) = preview(mt(); kwargs...)
function preview(str; tpl=preview_tpl, fontsize=FONTSIZE, pkgs=[])
    fnm = tempname()
    fnmtex = fnm * ".tex"
    open(fnmtex, "w") do io
        Mustache.render(io, tpl, (txt=str, fontsize=fontsize, pkgs=collect(pkgs)))
    end
    run(`cp $fnmtex /tmp/str.tex`)
    tectonic() do bin
        run(`$bin --print $fnmtex`)
    end
    run(`open $fnm.pdf`)

end

"""
    LaTeX′(str; kwargs...)

Parse `Markdown` string `str` and *then* run `LaTeX` function.

Allows LaTeX questions to use Markdown formatting.
"""
LaTeX′(str::Mustache.MustacheTokens; kwargs...) = LaTeX′(str(); kwargs...)
function LaTeX′(str; kwargs...)
    ast = parser(str)
    out =  sprint(io -> show(io, "text/latex", ast))
    LaTeX(out; kwargs...)
end

    
    
# Take a string of LaTeX code and produce an HTML fragment with tth
function latex_to_html(ltx)

    fnm = tempname() * ".tex"
    open(fnm, "w") do io
        Mustache.render(io, tth_tpl, (txt = ltx, pkgs=[]))
    end

    out = try
        io = IOBuffer()
        tth() do tthbinary
            run(pipeline(`$tthbinary -f5 -i -r  -t -w`, stdin=fnm, stdout=io, stderr=devnull))
        end
        out = String(take!(io))
        out = out[11:end-1]
        out
    catch err
        @warn "Issue running tth on ≪ $ltx ≫"
        ltx
    end

    out
    
end
    
# create HTML from string or mustache tokens
create_html(q::Mustache.MustacheTokens; kwargs...) = create_html(q();kwargs...)
function create_html(q; strip=false)
    
    ast = parser(q)
    qq =  sprint(io -> show(io, "text/html", ast))
    qq = chomp(qq)
    qq = replace(qq, "\n" => " ")
    if strip
        qq = qq[4:end-4]
    end
    qq

end
    
## IO helpers for managing pools within a single file
## see example-pool.jl for usage
# OPEN = JuliaBlackBoard.OPEN(@__FILE__)
# POOL = JuliaBlackBoard.POOL(@__FILE__)
function OPEN(SCRIPTNAME)
    bnm = replace(SCRIPTNAME, r".jl$" => "")
    fname = bnm * ".txt"
    (f) -> open(f, fname, "w")
end

function POOL(SCRIPTNAME)
    bnm = replace(SCRIPTNAME, r".jl$" => "")
    ctr = Ref(0)
    (f, io) -> begin
        num = ctr[] = ctr[] + 1
        question(io, OP, "XXX replace with pool-$num XXX")
        poolnm = bnm * "-pool-" * string(num) * ".txt"
        @show poolnm
        open(f, poolnm, "w")
    end
end


# Use CommonMark -- not Markdown-- for parsing, as we can
# overrule the latex bit easier

# set up common mark parser
parser = Parser()
enable!(parser, MathRule())
enable!(parser, DollarMathRule())



## Math display
## There are two ways to display math marked up in LaTeX within the question's HTML:
## * the default is to use `TtH` to convert LaTeX in to HTML. The drawback is some
##   things convert poorly, such as \bar{x} and \hat{x} type constructs.
## * Setting `ENV["USE_MATHJAX"] = true` will allow BlackBoard to render the formula
##   using MathML. This looks *much* better. **HOWEVER**, to see this one must edit and
##   save the question within BlackBoard.
## 
## By overwriting methods from CommonMark  non-fatal warnings are issued when precompiling
function CommonMark.write_html(::CommonMark.Math, rend, node, enter)
    if haskey(ENV, "USE_MATHJAX") && ENV["USE_MATHJAX"] == "true"
        print(rend.buffer, "\$\$" * node.literal * "\$\$")
    else
        tmp = latex_to_html("\$" * node.literal * "\$")
        CommonMark.tag(rend, "span", CommonMark.attributes(rend, node, ["class" => "math"]))
        print(rend.buffer, latex_to_html("\$" * node.literal * "\$"))
        CommonMark.tag(rend, "/span")
    end
end

function CommonMark.write_html(::CommonMark.DisplayMath, rend, node, enter)
    if haskey(ENV, "USE_MATHJAX") && ENV["USE_MATHJAX"] == "true"
        CommonMark.tag(rend, "div")##, CommonMark.attributes(rend, node, ["class" => "display-math"]))
        print(rend.buffer,  "\$\$" * node.literal* "\$\$</br>")
        CommonMark.tag(rend, "/div")
    else
        CommonMark.tag(rend, "div")##, CommonMark.attributes(rend, node, ["class" => "display-math"]))
        print(rend.buffer,  latex_to_html("\$\$" * node.literal* "\$\$"))
        CommonMark.tag(rend, "/div")
    end
end


## enhance BlackBoards display of code
const CODE_FACE = "Courier New"
function CommonMark.write_html(::CommonMark.Code, r, n, ent)
    CommonMark.tag(r, "code", CommonMark.attributes(r, n))
    CommonMark.tag(r, "font", ["face" => CODE_FACE])
    CommonMark.literal(r, CommonMark.escape_xml(n.literal))
    CommonMark.tag(r, "/font")
    CommonMark.tag(r, "/code")
end

function CommonMark.write_html(::CommonMark.CodeBlock, r, n, ent)

    nliteral = CommonMark.escape_xml(n.literal)
    nliteral = replace(nliteral, "\n" => "<br/>")
    
    info_words = split(n.t.info === nothing ? "" : n.t.info)
    attrs = CommonMark.attributes(r, n)
    if !isempty(info_words) && !isempty(first(info_words))
        push!(attrs, "class" => "language-$(escape_xml(first(info_words)))")
    end
    CommonMark.cr(r)
    CommonMark.tag(r, "pre")
    CommonMark.tag(r, "code", attrs)
    CommonMark.tag(r, "font", ["face" => CODE_FACE])
    CommonMark.literal(r, nliteral)
    CommonMark.tag(r, "/font")
    CommonMark.tag(r, "/code")
    CommonMark.tag(r, "/pre")
    CommonMark.literal(r, "<br/>")
    CommonMark.cr(r)
end

# write_latex adjustments
function CommonMark.write_latex(image::CommonMark.Image, w, node, ent)
    if ent
        image = CommonMark._smart_link(MIME"text/latex"(), image, node, w.env)
        CommonMark.cr(w)
        CommonMark.literal(w, "\\begin{figure}[H]\n") # add [H] and use `float` pkg
        CommonMark.literal(w, "\\centering\n")
        CommonMark.literal(w, "\\includegraphics{", image.destination, "}\n")
        CommonMark.literal(w, "\\caption{")
    else
        CommonMark.literal(w, "}\n")
        CommonMark.literal(w, "\\end{figure}")
        CommonMark.cr(w)
    end
end
    
#function CommonMark.write_latex(::CommonMark.Backslash, w, node, ent)
#    CommonMark.literal(w, ent ? raw"" : raw"")
#end

## Adjusments for `latex_escape`ing
let chars = Dict(
    ##        '^'  => "\\^{}",
    ##        '\\' => "{\\textbackslash}", # modify this one
    '~'  => "{\\textasciitilde}",
)
    for c in    "&%#[]" # took out _ \$, {} added []
    chars[c] = "\\$c"
    end
    global function CommonMark.latex_escape(w::CommonMark.Writer, s::AbstractString)
        for ch in s
            CommonMark.literal(w, get(chars, ch, ch))
        end
    end
end

