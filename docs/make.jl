using JuliaBlackBoard
using Documenter

makedocs(;
    modules=[JuliaBlackBoard],
    authors="jverzani <jverzani@gmail.com> and contributors",
    repo="https://github.com/jverzani/JuliaBlackBoard.jl/blob/{commit}{path}#L{line}",
    sitename="JuliaBlackBoard.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jverzani.github.io/JuliaBlackBoard.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jverzani/JuliaBlackBoard.jl",
)
