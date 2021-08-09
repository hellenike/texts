using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek
using CitableParserBuilder


f = "texts/lysias1.cex"
c = CitableCorpus.fromfile(CitableTextCorpus,f)


function tokenedition(c::CitableTextCorpus)
    newcorpus = []
    for cn in c.corpus
        psgbase = passagecomponent(cn.urn)
        urnbase = droppassage(cn.urn)
        tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)

        lexcount = 0
        nonlexcount = '@'
        for t in tokenlist
            if t.tokencategory == LexicalToken()
                lexcount = lexcount + 1
                nonlexcount = '@'
                #println("Lex count ", lexcount)
                psg = string(psgbase, ".", lexcount)
                urn = addpassage(urnbase, psg)
               push!(newcorpus, CitableNode(urn, t.text))

            else nonlexcount = nonlexcount + 1
                #println("NOLEX ", lowercase(nonlexcount))
                psg = string(psgbase, ".", lexcount, lowercase(nonlexcount))
                urn = addpassage(urnbase, psg)
                push!(newcorpus, CitableNode(urn, t.text))
            end
        end
    end
    newcorpus |> CitableTextCorpus
end

tkned = tokenedition(c)

open("data/tokenedition.cex","w") do io
    write(io, CitableCorpus.cex(tkned))
end