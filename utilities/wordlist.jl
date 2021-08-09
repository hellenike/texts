# Make a smart word list for morphological parsing:
# ie, a unique set of lexical tokens only that are 
# normalized to:
#
# - lower case
# - no breathings
#
using CitableText
using CitableCorpus
using Unicode
using Orthography
using PolytonicGreek


f = "texts/lysias1.cex"
c = CitableCorpus.fromfile(CitableTextCorpus,f)


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
    for cn in corp.corpus
        push!(words, stringsfornode(cn))
    end
    Iterators.flatten(words) |> collect |> unique |> sort
end
