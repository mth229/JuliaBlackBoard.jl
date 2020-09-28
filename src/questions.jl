"""
    question(io::IO, question_type::Symbol, q, answers...)

Write a question as a line in a tab separated file specified to `io`

* `io`: IO object specifying the file
* `question_type`: a symbol to dispatch on. 
* qanswers...`: Each question type has a different structure for answers


Currently these question types are supported 

* `MC`: multiple choice: Answer is tuple of pairs, e.g.: `("ans1" => true, "ans2" => false, ...)` -- exactly one is `true`
* `MA`  multiple answer: Answer is tuple of pairs, e.g.: `("ans1" => true, "ans2" => false, "ans3" => true, ...)` -- one or more is `true`
* `TF`  true false: answer is either `true` or `false`
* `ESS` Essay: no answer given
* `ORD` Ordered list.  Answer  is a tuple of options, e.g.: `("option 1", "option 2", ...)`
* `MAT` Matching. Answer is a tuple of pairs `("answer1"=>"match1", "answer2"=>"match2")`
* `FIB` fill in blank: question uses `()` for blanks;  answer is a tuple of possible answers, e.g. `("ans1", "ans2", ...)`.
* `FIB_PLUS` # variable list answers. Question use `()` for blanks. Answer is a tuple of pairs, of type `("variable1"=>(choices...), "variable2"=>(choices...), ...)`
* `FIL`  File upload: no answer
* `NUM`: numeric answer. Answer specified as `value, [tolerance]`
* `SR` short reponse "answer" is a prompt
* `OP` Likert scale. No answer
* `JUMBLED_SENTENCE`: Answer is a tuple of pairs ("choice1"=>("variable 1", "variable 2"), ..., nothing=("distractor 1", "distractor 2")). The pair with key `nothing` (no quotes) is optional.
* `QUIZ_BOWL`: Answer is a tuple of pairs ("answer 1"=>"question 1",  "question 2" => "answer 2",...)



"""
function question(io::IO, qt::Symbol, q, answers...)
    out = _writeq(Val(qt), q,  answers...)
    println(io, out)
end

## https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Reuse_Questions/Upload_Questions
## upload question types
## https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Question_Types

const MC = :MC   # multiple choice: ("ans1" => true, "ans2" => false, ...)
const MA = :MA   # multiple answer: ("ans1" => true, "ans2" => false, "ans3" => true, ...)
const TF = :TF   # true false: answer::Bool
const ESS = :ESS # Essay: no answer given
const ORD = :ORD # answer = tuple
const MAT = :MAT # answers, matches = tuple, tuple
const FIB = :FIB # fill in blank: answer = ("ans1", "ans2", ...)
const FIB_PLUS = :FIB_PLUS # variable list answers: variable, answer as tuples
const FIL = :FIL # File upload: no answer
const SR = :SR   # short reponse: answer = short_response
const OP = :OP   # opinion
const NUM = :NUM # numeric: answer, [tolerance]
const JUMBLED_SENTENCE = :JUMBLED_SENTENCE # choices, variables as tuples
const QUIZ_BOWL = :QUIZ_BOWL # question_words, phrases as tuple






# answers = ("ans1"=>true, "ans2"=>false, ...)
function _writeq(::Val{:MC}, q,  answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "MC"); print(io, "\t")
    print(io, qq)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
    out = String(take!(io))
    out
end

# answers = ("ans1"=>true, "ans2"=>false, ...)
function _writeq(::Val{:MA}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "MA"), print(io, "\t")
    print(io, qq)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
    out = String(take!(io))
end

# answer [true | false]
function _writeq(::Val{:TF}, q, answer::Bool)
    qq = create_html(q)
    "TF\t$qq\t$(string(answer))"
end


function _writeq(::Val{:ESS}, q, answers...)
    qq = create_html(q)
    "ESS\t$qq"
end

# q = "...() ... () ..."
# answers = (ans1, ..., ansn)
function _writeq(::Val{:ORD}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "ORD\t")
    print(io, qq); print(io, "\t")
    print(io, join(answers, "\t"))
    out = String(take!(io))
    out
end

## Matching
function _writeq(::Val{:MAT}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "MAT\t")
    print(io, qq); 
    for (a,m) in answers
        print(io, "\t")        
        print(io, create_html(a))
        print(io, "\t")
        print(io, m)
    end
    out = String(take!(io))
    out
end


# q = "...() ... () ..."
# answers = (ans1, ..., ansn)
function _writeq(::Val{:FIB}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "FIB\t")
    print(io, qq); print(io, "\t")
    print(io, join(answers, "\t"))
    out = String(take!(io))
    out
end

#
# answers = ("answer 1" => ("choice 1", "choice 2"))
function _writeq(::Val{:FIB_PLUS}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "FIB_PLUS\t")
    print(io, qq);
    n = length(answers)
    for i in eachindex(answers)
        (a, choices) = answers[i]
        print(io, "\t")        
        print(io, a)
        for choice in choices
            print(io,"\t")
            print(io, choice)
        end
        i < n && print(io, "\t")
    end
    out = String(take!(io))
    out
end


function _writeq(::Val{:FIL}, q, answers...)
    qq = create_html(q)
    "FIL\t$qq"
end


function _writeq(::Val{:SR}, q, answer = "A short response...")
    qq = create_html(q)
    sa = create_html(answer, strip=true)
    "SR\t$qq\t$sa"
end

function _writeq(::Val{:OP}, q, answers...)
    qq = create_html(q)
    "OP\t$qq"
end


# answer, [tolerance]
function _writeq(::Val{:NUM}, q,  answer, tolerance=nothing)
    qq = create_html(q)
    if isnothing(tolerance)
        out = "NUM\t$qq\t$answer"
    else
        out = "NUM\t$qq\t$answer\t$tolerance"
    end
    return out
end



## Matching
##     answers = ("var1" => ("choice 1", "choice 2"),
##               "var2" => ("choice 3", "choice 4"),
##               nothing => (....)
##               )
##    no_choices = ("choice 5", )

function _writeq(::Val{:JUMBLED_SENTENCE}, q, answers)
    qq = create_html(q)
    io = IOBuffer()
    print(io, "JUMBLED_SENTENCE\t")
    print(io, qq)
    no_choices = ()
    for (k,choices) in answers
        if k == nothing
            no_choices = choices
        else
            print(io, "\t")
            print(io, create_html(k))
            for choice in choices
                print(io, "\t")
                print(io, create_html(choice))
            end
        end
    end
    for choice in no_choices
        print(io, "\t")
        print(io, choice)
        choice != last(no_choices) && print(io, "\t")
    end
    
    out = String(take!(io))
    out
end


## Student gets answers, they provide question
function _writeq(::Val{:QUIZ_BOWL}, q, answers)
    
    qq = create_html(q)
    io = IOBuffer()
    print(io, "QUIZ_BOWL\t")
    print(io, qq); 
    for (q,ph) in answers
        print(io, "\t")        
        print(io, create_html(q))
    end
    print(io, "\t") #???
    for (q,ph) in answers
        print(io, "\t")
        print(io, create_html(ph))
    end
    out = String(take!(io))
    out
end
