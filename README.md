# JuliaBlackBoard

[![Build Status](https://travis-ci.com/MTH229/JuliaBlackBoard.jl.svg?branch=master)](https://travis-ci.com/MTH229/JuliaBlackBoard.jl)



Write BlackBoard questions for tests of question pools using Julia scripts.

The basic workflow is a Julia script is used to generate questions in a tab-separated-values file to
upload into BlackBoard. Both tests and pools (for randomizing test questions) provide "upload questions" for this format.

* Supports the question types of [BlackBoard](https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Reuse_Questions/Upload_Questions) (except `QUIZ_BOWL`)

* Can use markdown or LaTeX to author the questions. Markdown with
  LaTeX markup can be rendered (somewhat) as HTML by
  [tth](https://sourceforge.net/projects/tth). Questions specified in
  LaTeX can also be presented as png files created from the pdf output of
  running LaTeX (first page only).

* Random pools can be created through the use of Mustache templates to
  author questions to faciliate the randomization.


For example, a basic "quiz", (with just two non-randomized questions) might be produced with this script:

```
using JuliaBlackBoard
OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io

    ## --- first question ---
    q = mt"""
# Times tables:

What is 7 * 8
"""

    answer = 7 * 8
    question(io, NUM, q, answer)

    ## --- second question ---
    q = mt"""
# Division

What is ${{:x}} / {{:y}}$?
"""

    x, y = 56, 8
    answer = x/y
    question(io, NUM, q(x=x, y=y), answer)
end
```

If saved in `/tmp/test.jl`, say, and included into `Julia` with `include("/tmp/test.jl")`, a file `/tmp/test.txt` will be generated for upload into BlackBoard. 

After the first three lines, which are used to open a file with the same name as the script (with an extension `.txt`), a script just holds a series of questions. Each question needs a question (`q` above), a type (`NUM` above), and optionally an answer (e.g., `answer` above). The `io` that appears is just a way to write to the opened file.

In the above, the first question is straightforward. It uses a mix of [Markdown](https://www.markdownguide.org/cheat-sheet/) with LaTeX used for math markup only. The second is similar, but uses templated variables to fill in values for `x` and `y` in the question. This pattern is used for creating randomized pools.

The `question` command pieces together the entry for a question. As given here, the LaTeX markup is converted into HTML by `tth`. This is suitable for simple markup.

For the inclusion of an image of rendered LaTeX instead of HTML, the `mdquestion` function can be used instead of `question`.

The `lquestion` function can be used if the question is entirely marked up in LaTeX, as in this snippet, for example:

```
   q = mt"""
\section{Times Tables}

What is 7 * 8
"""
   lquestion(io, NUM, q, 7*8)
```   
  
For more control over the LaTeX conversion, such as using additional packages, see `?LaTeX`.


A basic pool of randomized questions can be generated through looping and templating. Though this particular example might be better done using the Formula Question type directly in BlackBoard, the increased flexibility of computing the answer can be exploited in more complicated questions:

```
using JuliaBlackBoard
OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io

  q = mt"""
# Times tables

What is ${{:a}} * {{:b}}$?
"""

  for a in 2:3, b in 2:3
    mdquestion(io, NUM, q(a=a,b=b), a*b)
  end
  
end
```	


The example script `example-pool.jl` shows how to mix the creation of a test and pools from the same file for merging together through the BlackBoard interface.


A kitchen-sink-type example showing the different question types is in the [examples](examples/test-examples.jl) directory.
