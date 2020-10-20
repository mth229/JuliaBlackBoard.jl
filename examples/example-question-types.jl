## Different question types
using JuliaBlackBoard


# used to create .txt file with same basename and same directory as script
OPEN = JuliaBlackBoard.OPEN(@__FILE__)

OPEN() do io

    q = mt"""
Simple **markdown** and $x^2$
"""

    qt = MC
    q = "Not no"
    answer = ("Yes" => true, "No" => false)
    question(io, qt, q, answer)

    qt = MA
    q = "Not no"
    answer =  ("Yes" => true, "No" => false, "Maybe"=>true)
    question(io, qt, q, answer)

    qt = TF
    q = mt"""Not false"""    
    answer = true
    question(io, qt, q, answer)

    qt = ESS
    q = "Essay"
    answer = nothing
    question(io, qt, q, answer)

    qt = ORD
    q = "Sort in order"
    answer = ("one", "two", "three")
    question(io, qt, q, answer)

    qt = MAT
    q = "Match spelling with number"
    answer=("one"=>"1", "two"=>"2", "three"=>"3")
    question(io, qt, q, answer)

    qt = FIB
    q = mt"""Positive integer less than $2^2$ (spell)"""
    answer=("one", "two", "three")
    question(io, qt, q,  answer)
    
    qt = FIB_PLUS
    q = mt"""[var1] and [var2] years ago, the founding fathers..."""
    answer=("var1"=>("four", "Four", "4"), "var2"=>("seven", "y"))
    question(io, qt, q, answer)
    
    qt = FIL
    q = "file upload"
    answer=nothing
    question(io, qt, q, answer)    

    qt = SR
    q = "short response"
    answer="short prompt"
    question(io, qt, q, answer)    

    qt = OP
    q = "Rate this"
    answer=nothing
    question(io, qt, q, answer)    
    
    qt = NUM
    q = mt"""The number $1$"""
    answer = 1
    question(io, qt, q, answer)

    qt = NUM
    q = mt"""A number in $[0.9, 1.1]$"""    
    answer = (1, 0.1)
    question(io, qt, q, answer...)

    qt = JUMBLED_SENTENCE
    qq = "The [var1] brown [var2] jumped over the lazy [var3]"
    answer = ("var1"=>"quick", "var2"=>"fox", "var3"=>"dog", nothing=>("cat", "slow", "fast"))
    question(io, qt, qq, answer)
end
