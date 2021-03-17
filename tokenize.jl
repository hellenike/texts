using CitableText
using Orthography
using Unicode
using FreqTables
using PolytonicGreek

f = "texts/lysias1.cex"
output = "histo-1.cex"

function cleangreek(s)
    normed = Unicode.normalize(s, :NFKC)
    Unicode.normalize(normed, stripmark=true)
end

function lextokens(src)
    c = CitableText.fromfile(CitableCorpus,f)
    lextokens = []
    for cn in c.corpus
        tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
        for t in tokenlist
            if (t.tokencategory ==  Orthography.LexicalToken())
                push!(lextokens, cleangreek(t.text))
            end
        end
    end
    lextokens
end

function histogram(src, target)
    tkns = lextokens(src)
    hist = sort(freqtable(tkns); rev=true)
    output = []
    for n in names(hist)[1]
        push!(output, string(n,"|", hist[n]))
    end
    open(target,"w")  do io
        println(io, join(output, "\n"))
    end
end