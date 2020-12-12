# Including Plots output into a question can
# be achieved in various ways, as illustrated
# here.


using JuliaBlackBoard
using Plots
gr()

OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io



    ## With Markdown (the default), we include a plot
    ## through the image markup: `![caption]({{{:plot}}})` where
    ## `{{{:plot}}}` is an encoded plot given by passing the
    ## value:
    ## * `q(plot=Plot(p))` with `p` a `Plots` object, or
    ## * `q(plot=File(fname))` where `fname` is the name of a file where the plot is
    ##    written. This can be useful, say, when a different program is used to generate
    ##    the plot (e.g., `RCall`).
    p = plot(sin, 0, 2pi)

    q = mt"""
# include via `Plot` and the markdown syntax for a plot:

![caption]({{{:plot}}})
"""

    question(io, ESS, q(plot=Plot(p)))

    p = plot(cos, 0, 2pi)
    pngfile = tempname() * ".png"
    savefig(p, pngfile)  # save to a file
    
    q = mt"""
# include a plot which is stored in a file

![caption]({{{:plot}}})
"""
    question(io, ESS, q(plot=File(pngfile)))

    ## With LaTeX there are some subtleties:
    ##
    ## The easiest way to generate pdf output is with the `ltx"""` string macro,
    ## but this won't allow easy substitution into an `\includegraphics`, as the
    ## spaces aren't allowed and `\includegraphics{{{{:plot}}}}` isn't parsed correctly for
    ## substitution.
    ##
    ## So, we have two ways. You can avoid any string macro and use a raw string, then
    ## regular interpolation (via the $) is possible.
    ## Alternatively, we show how to use a different tag in the Mustache template.
    ## For both, you need to explicitly call `LaTeX()`, as below.
    ##
    ## First without a string Maco
    q = """
This is \\LaTeX with inline math (\$\\sin(x)^2\$) and here we have a plot 
(note the necessary escaping.)

\\includegraphics[width=4in, height=3in]{$pngfile}
"""
    question(io, ESS, LaTeX(q))

    
    ## Next we use `MT"""` which parses the tags `<<`, `>>`. We have an extra `{}` to
    ## ensure no HTML substitution is performed.
    q = MT"""
This is cumbersome, as we need different tags for Mustache substitution. 

\includegraphics[width=4in, height=3in]{<<{:plot}>>}

This shows how one might do a second round of substitution, for example a variable {{:a}}.

"""

    qq = q(plot=pngfile)
    qqq = JuliaBlackBoard.Mustache.render(qq, a="(a)")
    question(io, ESS, LaTeX(qqq))


    ## Finally, using the `pgfplotsx` backend, plots can be written as `tikz` files for
    ## inclusion. For this the contents of the file are included. (Not the plot object.)
    ## The `Tikz` function makes this straightforward. This substitution allows the use
    ## of the `ltx"""` string macro and the usual substitution:

    pgfplotsx() # use PGFPlotsX backend for Plots
    p = plot(asin, -1/2, 1/2);
    tikzfile = tempname() * ".tikz"
    savefig(p, tikzfile)

    q = ltx"""
A Tikz plot requires the contents of a file to be included, as illustrated here.\\

{{{:plot}}}

"""

    question(io, ESS, q(plot=Tikz(tikzfile)))
    
end


