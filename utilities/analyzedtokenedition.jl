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


analyzedcorpus = []
for cn in tkncorpus.corpus
    normed = normalizetxt(cn.text)
    if haskey(parsedict, normed)
        for a in parsedict[normed]
            push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|", a))
        end

        #push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|", parsedict[normed]))
    else
        push!(analyzedcorpus, string(cn.urn.urn, "|", cn.text,"|missing"))
    end
end

open("data/analyzededition.cex","w") do io
    write(io, join(analyzedcorpus, "\n"))
end
