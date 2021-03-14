using CitableText
using Orthography
using Unicode
using FreqTables

f = "texts/lysias1.cex"
c = CitableText.fromfile(CitableCorpus,f)

function cleangreek(s)
    normed = Unicode.normalize(s, :NFKC)
    Unicode.normalize(normed, stripmark=true)
end

lextokens = []
for cn in c.corpus
    tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
    for t in tokenlist
        if (t.tokencategory ==  Orthography.LexicalToken())
            push!(lextokens, cleangreek(t.text))
        end
    end
end



hist = sort(freqtable(lextokens); rev=true)


output = []
for n in names(hist)[1]
    push!(output, string(n,"|", hist[n]))
end

open("hist.cex","w")  do io
    println(io, join(output, "\n"))
end