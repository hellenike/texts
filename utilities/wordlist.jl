# Make a smart word list for morphological parsing:
# ie, a unique set of lexical tokens only that are 
# normalized to:
#
# - lower case
# - no breathings
#
using CitableBase
using CitableText
using CitableCorpus
using Orthography
using PolytonicGreek
using Kanones
using SplitApplyCombine


f = "texts/lysias1.cex"
c = fromcex(f, CitableTextCorpus,FileReader)
o = literaryGreek() 
tkns = tokenize(c, o)
lexprs = filter(pr -> pr[2] == LexicalToken(), tkns)
lexstrs = map(pr -> Kanones.knormal(pr[1].text), lexprs)
grouped = group(lexstrs)
counts = []
for k in keys(grouped)
    push!(counts, (k, length(grouped[k])))
end
sorted = sort(counts, by = pr -> pr[2], rev = true)

open("wordcounts.csv", "w") do io
    write(io, join(map(pr -> string(pr[1],",",pr[2]), sorted) ,"\n"))
end


#=
# Extract normalized set of strings for all lexical items
# in a citable node.
function stringsfornode(cn)
    tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
    lex = filter(t -> t.tokencategory == LexicalToken(), tokenlist)
    rawtext =  map(t -> t.text, lex) 
    PolytonicGreek.rmaccents.(lowercase.(rawtext)) |> unique
end


# Compose wordlist for a corpus.
function wordlist(corp::CitableTextCorpus)
    words = []
    for cn in corp
        push!(words, stringsfornode(cn))
    end
    Iterators.flatten(words) |> collect |> unique |> sort
end

words = wordlist(c)
open("wordlist.txt", "w") do io
    write(io, join(words,"\n"))
end
=#