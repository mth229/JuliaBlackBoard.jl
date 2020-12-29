## No * `QUIZ_BOWL`: 


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
* `MAT` Matching. Answer is a tuple of answer-match pairs `("answer1"=>"match1", "answer2"=>"match2")`
* `FIB` fill in blank: question uses `____` for blank;  answer is a tuple of possible answers, e.g. `("ans1", "ans2", ...)`.
* `FIB_PLUS`  fill in blank plus. Question has variables marked as [var1], .... Answer is collection of pairs of the form `"var1" => ("possible", "exact", "matches")`
* `FIL`  File upload: no answer
* `NUM`: numeric answer. Answer specified as `value, [tolerance]`
* `SR` short reponse "answer" is a prompt
* `OP` Likert scale. No answer
* `JUMBLED_SENTENCE`: Question marks blanks with [var1], [var2] (variable names enclosed in []); answer is a collection of pairs of the form `"var"=>"choice"` with a special pair possible of the type `nothing=>("distractor 1", "distractor 2", ...)` for 1 or more distractors

"""
function question(io::IO, qt::Symbol, q, answers...)

    qq = create_html(q)
    print(io, string(qt))
    print(io, "\t")
    print(io, qq)
    _write_answer(io, Val(qt), answers...)
    println(io)
    
end

## helpers
## XXX Deprecate these
@deprecate lquestion(io::IO, qt::Symbol, q, answers...)  question(io, qt, LaTeX(q), answers...)
@deprecate mdquestion(io::IO, qt::Symbol, q, answers...) question(io, qt, LaTeX′(q), answers...)




## https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Reuse_Questions/Upload_Questions
## upload question types
## https://help.blackboard.com/Learn/Instructor/Tests_Pools_Surveys/Question_Types

const MC = :MC   # multiple choice: ("ans1" => true, "ans2" => false, ...)
const MA = :MA   # multiple answer: ("ans1" => true, "ans2" => false, "ans3" => true, ...)
const TF = :TF   # true false: answer::Bool
const ESS = :ESS # Essay: no answer given
const ORD = :ORD # answer = answers, in order, in container, `("one", "two", "three")`
const MAT = :MAT # answer-match pairs, e.g. `("answer"=>"match", "answer"=>"match"...)`
const FIB = :FIB # fill in blank: user answer ∈ ("ans1", "ans2", ...)
const FIB_PLUS = :FIB_PLUS # variable list answers: variable, answer as tuples
const FIL = :FIL # File upload: no answer
const SR = :SR   # short reponse: answer = short_response
const OP = :OP   # opinion
const NUM = :NUM # numeric: answer, [tolerance]
const JUMBLED_SENTENCE = :JUMBLED_SENTENCE # choices, variables as tuples
const QUIZ_BOWL = :QUIZ_BOWL # question_words, phrases as tuple


# answers = ("ans1"=>true, "ans2"=>false, ...)
function _write_answer(io::IO, ::Val{:MC}, answers)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
end

# answers = ("ans1"=>true, "ans2"=>false, ...)
function _write_answer(io::IO, ::Val{:MA}, answers)
    for (k,v) in answers
        print(io, "\t")
        print(io, create_html(k, strip=true))
        print(io, "\t")
        print(io, v ? "correct" : "incorrect")
    end
end

# answer [true | false]
function _write_answer(io::IO, ::Val{:TF}, answer::Bool)
    print(io, "\t")        
    print(io, string(answer))
end

# no answer
function _write_answer(io::IO, ::Val{:ESS}, answers...)
    # nothing
end

# answers = (ans1, ..., ansn)
function _write_answer(io::IO, ::Val{:ORD}, answers)
    print(io, "\t")        
    print(io, join(answers, "\t"))
end

## Matching answer is answer-match pairs
function _write_answer(io::IO, ::Val{:MAT}, answers)
    for (a,m) in answers
        print(io, "\t")        
        print(io, create_html(a, strip=false))
        print(io, "\t")
        print(io, create_html(m,strip=false))
    end
end


# question has ____ marking blank
# answers = (ans1, ..., ansn)
function _write_answer(io::IO, ::Val{:FIB}, answers)
    print(io, "\t")            
    print(io, join(answers, "\t"))
end

# quesstin has [var1], [var2], ...
# answers = ("var1" => ("possible", "exact", matches"), "var2"=> ...)
function _write_answer(io::IO, ::Val{:FIB_PLUS}, answers)
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


function _write_answer(io::IO, ::Val{:FIL}, answers...)
    # nothing
end


function _write_answer(io::IO, ::Val{:SR}, answer = "A short response...")
    print(io, "\t")        
    print(io, create_html(answer, strip=true))
end

function _write_answer(io::IO, ::Val{:OP}, answers...)
    # nothing
end


# answer, [tolerance]
function _write_answer(io::IO, ::Val{:NUM},  answer, tolerance=nothing)
    print(io, "\t")        
    print(io, answer)
    if !isnothing(tolerance)
        print(io, "\t")
        print(io, tolerance)
    end
end




# ("var"=>"choice", "var1"=>"choice", nothing=>(distractors,))
# no markup for "choice"
function _write_answer(io::IO, ::Val{:JUMBLED_SENTENCE},  answers)
    do_last = ()
    for (var, choice) in answers
        if var == nothing
            do_last = choice
            continue
        end
        print(io, "\t")
        print(io, choice)
        print(io, "\t")
        print(io, var)
        print(io, "\t")
    end
    for choice in do_last
        print(io, "\t")
        print(io, choice)
        print(io, "\t")
    end
end


## Student gets answers, they provide question
# function _write_answer(io::IO, ::Val{:QUIZ_BOWL}, answers)
#     for (q,ph) in answers
#         print(io, "\t")
        
#         print(io, q)
#     end
#     print(io, "\t") #??? 
#     for (q,ph) in answers
#         print(io, "\t")
#         print(io, ph)
#     end
#     out = String(take!(io))
#     out
# end
