using CitableText
using Orthography
using Unicode
using FreqTables
using PolytonicGreek

f = "texts/lysias1.cex"
output = "histo-1.cex"

# src is a filename.
# Create a list of lexical tokens
function lextokens(src)
    c = CitableText.fromfile(CitableCorpus,f)
    lextokens = []
    for cn in c.corpus
        tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
        for t in tokenlist
            if (t.tokencategory ==  Orthography.LexicalToken())
                push!(lextokens, rmaccents(t.text))
            end
        end
    end
    lextokens
end


# Write a histogram of lexical tokens in src to file target
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

# histogram(f, output)