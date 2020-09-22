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
