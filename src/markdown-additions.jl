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

using Mustache
using Tectonic
using ImageMagick

const WHITE = ImageMagick.RGBA{ImageMagick.N0f16}(1.0,1.0,1.0,0.0)

const latex_tpl = mt"""
\documentclass[{{:pt}}pt]{article}
\usepackage{tikz}
\begin{document}
\thispagestyle{empty}
{{{:txt}}}
\end{document}
"""


function latex_to_image(str;pt=24, tpl=latex_tpl)
    fnm = tempname()
    fnmtex = fnm * ".tex"
    open(fnmtex, "w") do io
        Mustache.render(io, tpl, (txt=str,pt=pt))
    end

    tectonic() do bin
        run(`$bin $fnmtex`)
    end
    
    a = ImageMagick.load(fnm * ".pdf")
    rs = [all(a[i,:] .== WHITE) for i in 1:size(a, 1)]
    cs = [all(a[:,j] .== WHITE) for j in 1:size(a, 2)]
    rₘ = findfirst(iszero, rs)
    rₙ = findlast(iszero, rs)
    cₘ = findfirst(iszero, cs)
    cₙ = findlast(iszero, cs)

    b = a[rₘ:rₙ, cₘ:cₙ]

    fnmpng = tempname() * ".png"
    ImageMagick.save(fnmpng, b)

    fnmpng
end

function LaTeX(str; pt=24, tpl=latex_tpl)
    fnm = latex_to_image(str, pt=pt, tpl=tpl)
    img = base64encode(read(fnm, String))
    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,img)
    String(take!(io))
end

function LaTeX(tpl, context; pt=24)
    str = Mustache.render(tpl, context)
    LaTeX(str, pt=pt)
end

export LaTeX


function Base.show(io::IO, ::MIME"text/html", md::Markdown.Image)

    println(io, """<figure><img src="$(md.url)"  alt="$(md.alt)"><figcaption>$(md.alt)</figcaption></figure>""")

end

# create HTML
function create_html(q, context; strip=false)
    qq =  sprint(io -> show(io, "text/html", Markdown.parse(Mustache.render(q, context))))
    qq = replace(qq, "\n" => "")
    qq = qq[23:end-6]
    if strip
        qq = qq[4:end-5]
    end
    qq
end
