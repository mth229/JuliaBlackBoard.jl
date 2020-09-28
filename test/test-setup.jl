using JuliaBlackBoard

# using StatsBase: mean
mean(x) = sum(x)/length(x)


dirnm = dirname(@__FILE__)
basenm = replace(basename(@__FILE__), r".jl$" => "") # grab names

open(joinpath(dirnm, "$basenm.txt"), "w") do io

    # -- Question ---
    # use a NUM type with answer computed
    q = mt"""
# The mean

Find the mean of

```
2 3 4
```    
"""

    question(io, NUM,q,mean((2,3,4)))

    # -- Question ---
    # using some latex to test tth
    q = mt"""
# The mean

Find the mean, $(x_1 + \cdots x_n)/n$, of

```
{{{:xs}}}
```    
"""

    for xs in ((2,3,4),
               (3,4,5))
        question(io, NUM, q(xs = join(xs, ",")), mean(xs))
    end

    # -- Question ---
    # using all latext to test LaTeX and tectonic installation

     q = mt"""
\section{The mean}

Find the mean, $\bar{x}$, of

\begin{verbatim}
2 3 4
\end{verbatim}
"""

    question_tpl = mt"""![]({{{:latex}}})"""
    latex = LaTeX(q)
    question(io, NUM, question_tpl(latex=latex), mean((2,3,4)))

end

    

    
              
