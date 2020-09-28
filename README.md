# JuliaBlackBoard

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jverzani.github.io/JuliaBlackBoard.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jverzani.github.io/JuliaBlackBoard.jl/dev)
[![Build Status](https://travis-ci.com/jverzani/JuliaBlackBoard.jl.svg?branch=master)](https://travis-ci.com/jverzani/JuliaBlackBoard.jl)
[![Coverage](https://codecov.io/gh/jverzani/JuliaBlackBoard.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jverzani/JuliaBlackBoard.jl)



Write BlackBoard questions for question pools or tests within Julia.

A simple numeric answer question



The basic workflow is a Julia script is used to generate questions in a tab-separate-values file to
upload into BlackBoard.

* Supports the question types of classic BlackBoard

* Can use markdown or LaTeX to author the questions. Markdown with
  LaTeX markup can be rendered (somewwhat) if
  [tth](https://sourceforge.net/projects/tth) is installed. Questions
  specified in LaTeX can be presented as png files created from the
  pdf output of running LaTeX (first page onlye).

* Random pools can be created through the use of Mustache templates to
  author questions to faciliate the randomization.



A kitchen-sink-type example is given [here](examples/test-examples.jl)
