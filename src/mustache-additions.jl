## Modification to Mustache and friends to make this easier to work with

## Image substitution: LaTeX, Plot, File
## in Markdown ![alt](url) will display a graphic image by url
## We use mustache and a few files to add other images:
## The pattern: ![alt]({{{:img}}}) can hold
## * A png of LaTeX output when `img=LaTeX(str)`
## * a Plots plot, `p`, when `img=Plot(p)`
## * a local file when `img=File(file_name)`.
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


# used by tth
const latex_tpl = mt"""
\documentclass{article}
\usepackage{amssymb}
{{#:pkgs}}
\usepackage{ {{.}} }
{{/:pkgs}}

\begin{document}
\thispagestyle{empty}
%\{{:fontsize}}
{{{:txt}}}
\end{document}
"""

# use by LaTeX and preview
const preview_tpl = mt"""
\documentclass{article}
\usepackage{amssymb}
\usepackage{graphicx}
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


function _findfirst(rs)
    i = findfirst(iszero, rs)
    i == nothing ? 1 : i
end

function _findlast(rs)
    i = findlast(iszero, rs)
    i == nothing ? length(rs) : i
end

# convert latex to png file
## Much better on apple systems, as `sips` is available
latex_to_image(str::Mustache.MustacheTokens;kwargs...) = latex_to_image(str(); kwargs...)
function latex_to_image(str;  fontsize="LARGE", tpl=preview_tpl, pkgs=[])

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
        return fnmpng
    end

    imagemagick_convert() do bin
        run(`$bin -density 150 -depth 8 -quality 100 $fnmpdf $fnmpng`)
    end

    return fnmpng

    # Keep in case useful elsewhere; no longer used as with preview no need to trim
    # hack to trim pdf and write out png
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


# show the png file generated
preview(mt::Mustache.MustacheTokens; kwargs...) = preview(mt(); kwargs...)
function preview(str; tpl=preview_tpl, fontsize="LARGE", pkgs=[])
    fnm = tempname()
    fnmtex = fnm * ".tex"
    open(fnmtex, "w") do io
        Mustache.render(io, tpl, (txt=str, fontsize=fontsize, pkgs=collect(pkgs)))
    end
    run(`cp $fnmtex /tmp/str.tex`)
    tectonic() do bin
        run(`$bin $fnmtex`)
    end
    run(`open $fnm.pdf`)

end

# go from LaTeX snippet to a png file
# very lossy unless `standalone` is used
# Use as in
# ![]({{{:latex}}}
# and then `latex=LaTeX(str)` in the mustache context
function LaTeX(str;
               tpl=preview_tpl,
               fontsize="LARGE",  pkgs=[])

    
    fnm = latex_to_image(str, fontsize=fontsize, tpl=tpl, pkgs=pkgs)

    img = base64encode(read(fnm, String))
    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,img)
    String(take!(io))
end


# Use CommonMark -- not Markdown-- for parsing, as we can
# overrule the latex bit easier

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
        CommonMark.tag(rend, "span", CommonMark.attributes(rend, node, ["class" => "math"]))
        print(rend.buffer, latex_to_html("\$" * node.literal * "\$"))
        CommonMark.tag(rend, "/span")
    end
end

function CommonMark.write_html(::CommonMark.DisplayMath, rend, node, enter)
    if haskey(ENV, "USE_MATHJAX") && ENV["USE_MATHJAX"] == "true"
        CommonMark.tag(rend, "div")##, CommonMark.attributes(rend, node, ["class" => "display-math"]))
        print(rend.buffer,  "</br>\$\$" * node.literal* "\$\$</br>")
        CommonMark.tag(rend, "/div")
    else
        CommonMark.tag(rend, "div")##, CommonMark.attributes(rend, node, ["class" => "display-math"]))
        print(rend.buffer,  latex_to_html("\$\$" * node.literal* "\$\$"))
        CommonMark.tag(rend, "/div")
    end
end

function CommonMark.write_html(::CommonMark.Code, r, n, ent)
    CommonMark.tag(r, "code", CommonMark.attributes(r, n))
    CommonMark.tag(r, "font", ["face" => "Courier New"])
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
    CommonMark.tag(r, "font", ["face" => "Courier New"])
    CommonMark.literal(r, nliteral)
    CommonMark.tag(r, "/font")
    CommonMark.tag(r, "/code")
    CommonMark.tag(r, "/pre")
    CommonMark.literal(r, "<br/>")
    CommonMark.cr(r)
end

# set up common mark parser
parser = Parser()
enable!(parser, MathRule())
enable!(parser, DollarMathRule())

# create HTML from string or mustache tokens
create_html(q::Mustache.MustacheTokens; kwargs...) = create_html(q();kwargs...)
function create_html(q; strip=false)
    
    ast = parser(q)
    qq =  sprint(io -> show(io, "text/html", ast))
    qq = replace(qq, "\n" => "")
    if strip
        qq = qq[4:end-4]
    end
    qq

end

# Take a string of LaTeX code and produce an HTML fragment
function latex_to_html(ltx)


    fnm = tempname()
    _tex =  fnm * ".tex"
    _html = fnm * ".html"
    open(_tex, "w") do io
        Mustache.render(io, latex_tpl, (txt = ltx, fontsize="large", pkgs=[]))
    end

    out = try
        io = IOBuffer()
        tth() do tthbinary
            run(pipeline(`$tthbinary -f5 -i -r  -t -w`, stdin=_tex, stdout=io, stderr=devnull))
        end
        out = String(take!(io))
        out = out[11:end-1]
        out
    catch err
        @warn "Issue running tth. Is it installed? https://sourceforge.net/projects/tth/"
        ltx
    end

    out
    
end
    
    
