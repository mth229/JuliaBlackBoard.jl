using JuliaBlackBoard

# used to create .txt file with same basename and same directory as script
OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io

    ## Questions can be simple strings
    ## The text is in markdown
    q = "What is *1 + 1*?"
    question(io, NUM, q, 1+1)

    ## Typically though questions use Mustache templates
    ## substitution can be done by named arguments
    q = mt"""
# Addition 

What is *{{:x}} + {{:y}}*?
"""
    x, y = 2, 3
    question(io, NUM, q(x=x, y=y), x + y)

    ## Math Markup
    ##
    ## BlackBoard's question editor has a formula editor for math
    ## dispaly.  The math editor is written by WIRIS and based on
    ## standards like MathML for internal representation and the PNG
    ## image format for displaying formulas. The math editor is based
    ## on Javascript and runs on any browser and operating system,
    ## including smartphones and tablets.
    ##
    ## This is not directly accessible from a file upload, thoug the
    ## last example shows how it can be. Rather, from within this framework,
    ## we can use LaTeX to mark up questions in different ways


    ## Using TtH for markup
    ## LaTeX-formatted equations are rendered in HTML through TtH
    ## This has limitations for some formula (e.g. \bar{x} or \frac{x}{y}), but
    ## is okay.
    q = mt"""
# Division

Compute $z$ where

$$
z = \frac{ {{:x}} }{ {{:y}} }.
$$
"""
    x, y = 4, 2
    question(io, NUM, q(x=x, y=y), x/y)

    ## using LaTeX. The entire question can be a png image from
    ## LaTeX output. The `LaTeX` command formats the question.
    ## using `lquestion` will wrap `str` in `LaTeX`.
    q = mt"""
\noindent\textbf{Fractions}

Compute $z$ where 
$$
z = \frac{1}{ {{:x}} } + \frac{1}{ {{:y}} }.
$$
"""
    x, y = 2, 3
    str = q(x=x, y=y)
    question(io, NUM, LaTeX(str), 1/x + 1/y)

    ## Using markdown and using CommonMark to convert to latex, then running LaTeX
    ## This is done by `LaTeX′` (`\prime[tab]`).
    q = mt"""
# exponents

Compute $z$ where
$$
z = {{:n}}^{{:m}}
$$

"""
    n,m = 2, 3
    str = q(n=n, m=m)
    question(io, NUM, LaTeX′(str), n^m)


    
    ## Mix and match. It seems silly, but ala y2k's LaTeX2HTML
    ## The `LaTeX(str)` command produces an image that can be included within
    ## a markdown-formatted question, as follows:
    q = mt"""
# subtraction

Compute {{:latex_z}}  where

{{:latex_x_y}}
"""
    x, y = 5, 3
    latex_z = LaTeX(mt"$z$")
    latex_x_y = LaTeX(mt"$$z = {{:x}} - {{:y}}$$"(x=x, y=y))
    question(io, NUM, q(latex_z=latex_z, latex_x_y=latex_x_y), x - y)

    ## Finally, in the question editor on BlackBoard, LaTeX markup can be
    ## used. (Inline markup is indicated with `$$...$$`.) *However*,
    ## this only renders after the question is submitted for
    ## saving. (At which point, an image is generated that is
    ## displayed).  If the environment variable `USE_MATHJAX` is set
    ## to `true`, then the markup will include the dollar signs. The
    ## question must be displayed in the BlackBoard editor and
    ## submitted for the image to be generated (though not
    ## modified). (https://blackboard.secure.force.com/publickbarticleview?id=kA339000000L6QH)

    ENV["USE_MATHJAX"] = true

    q = mt"""
# Division

Compute $z$ where

$$
z = \frac{ {{:x}} }{ {{:y}} }.
$$
"""
    x, y = 7, 2
    question(io, NUM, q(x=x, y=y), x/y)

    ENV["USE_MATHJAX"] = false # restore default
    
    
end
