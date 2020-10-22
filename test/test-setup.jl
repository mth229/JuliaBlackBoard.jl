using JuliaBlackBoard

mean(x) = sum(x)/length(x)

OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io

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
    # using some latex to test markdown -> LaTeX
    q = mdltx"""
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
    # using all latex to test LaTeX and tectonic installation

     q = ltx"""
\section{The mean}

Find the mean, $\bar{x}$, of

\begin{verbatim}
2 3 4
\end{verbatim}
"""

    question(io, NUM,  q, mean((2,3,4)))

end

    

    
              
