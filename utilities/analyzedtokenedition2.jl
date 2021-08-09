# Better version of analyzed token file:
#
# create a delimited text file with analyses for tokens identifed by CTS URN, and 
# category for token.
#
using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek
using CitableParserBuilder



analysisfile = "analyses.cex"
lines = readlines(analysisfile)

parsedict = Dict()
for l in lines
    halves = split(l, "|")
    if haskey(parsedict,halves[1])
        parses = parsedict[halves[1]]
        push!(parses, halves[2])
        parsedict[halves[1]] = parses
    elseif isempty(halves[2])
        parsedict[halves[1]] = []
    else
        parsedict[halves[1]] = [halves[2]]
    end
end

tknfile = "data/tokenedition.cex"
tkncorpus = CitableCorpus.fromfile(CitableTextCorpus, tknfile)

function normalizetxt(s)
    rmaccents(s) |> lowercase
end

function stringforcat(tokencat) 
    if tokencat == LexicalToken()
        "lexical"
    elseif tokencat == PunctuationToken()
        "punctuation"
    else
        "other"
    end
end

analyzedcorpus = ["text|token|analysis|tokencategory"]
for cn in tkncorpus.corpus
    tkn = PolytonicGreek.tokenizeLiteraryGreek(cn.text)[1]
    normed = normalizetxt(cn.text)
    if haskey(parsedict, normed)
        if isempty(parsedict[normed])
            push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|missing|", stringforcat(tkn.tokencategory)))
    
        else
            for a in parsedict[normed]
                push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|", a, "|", stringforcat(tkn.tokencategory)))
            end
        end

        #push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|", parsedict[normed], "|", stringforcat(tkn.tokencategory)))

    else
        push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|missing|", stringforcat(tkn.tokencategory)))
    end
end

open("data/analyzededition.cex","w") do io
    write(io, join(analyzedcorpus, "\n"))
end
