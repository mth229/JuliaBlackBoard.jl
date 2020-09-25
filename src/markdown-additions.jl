# plots. Workflow
# template include: ![Alt]({{{:figure}}})
# use (figure=Plot(p), ...) for context
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
export Plot


## File ![alt](File("imagefile.png"))
function File(p)
    img = base64encode(read(p, String))
    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,img)
    String(take!(io))
end
export File

const WHITE = ImageMagick.RGBA{ImageMagick.N0f16}(1.0,1.0,1.0,0.0)

const latex_tpl = mt"""
\documentclass{article}
\usepackage{amssymb}
\usepackage{graphicx}
\usepackage{tikz}
{{#:pkgs}}
\usepackage{ {{.}} }
{{/:pkgs}}

\begin{document}
\thispagestyle{empty}
\{{:fontsize}}
{{{:txt}}}
\end{document}
"""


const preview_tpl = mt"""
\documentclass[24pt]{article}
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

# convert to png file
function latex_to_image(str;  fontsize="LARGE", tpl=preview_tpl, pkgs=[])

    fnm = tempname()
    fnmtex = fnm * ".tex"
    fnmpdf = fnm * ".pdf"
    fnmpng = fnm * ".png"
    
    open(fnmtex, "w") do io
        Mustache.render(io, tpl, (txt=str, fontsize=fontsize, pkgs=collect(pkgs)))
    end
    tectonic() do bin
        run(`$bin $fnmtex`)
    end

    run(`cp $fnmtex /tmp/test.tex`)

    if Sys.isapple()
        run(`sips -s format png $fnmpdf --out $fnmpng`)
        return fnmpng
    end
    
    a = load(fnmpdf)
    save(fnmpng, a, quality=100)
    return fnmpng

    # Keep in case useful elsewhere; no longer used as with preview no need to trim
    # hack to trim pdf and write out png
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
function LaTeX(str, context=nothing;
               tpl=preview_tpl,
               fontsize="LARGE",  pkgs=[])

    if !isnothing(context)
        str = Mustache.render(str, context)
    end

    fnm = latex_to_image(str, fontsize=fontsize, tpl=tpl, pkgs=pkgs)

    img = base64encode(read(fnm, String))
    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,img)
    String(take!(io))
end


export pdflatex, LaTeX, preview


function Base.show(io::IO, ::MIME"text/html", md::Markdown.Image)
    # img not object
    println(io, """<figure><img src="$(md.url)"  alt="$(md.alt)"><figcaption>$(md.alt)</figcaption></figure>""")

end

# create HTML for question and context
function create_html(q, context; strip=false)

    str = Mustache.render(q, context)
    qq =  sprint(io -> show(io, "text/html", Markdown.parse(str)))
    qq = replace(qq, "\n" => "")
    qq = qq[23:end-6]
    if strip
        qq = qq[4:end-5]
    end
    qq

end
