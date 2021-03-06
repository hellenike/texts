# Define functions to tokenize a text of Lysias and create
# a histogram of lexical tokens.
#
using CitableText, CitableCorpus
using Orthography
using Unicode
using FreqTables
using PolytonicGreek

f = "texts/lysias1.cex"
output = "histo-1.cex"

# src is a filename.
# Create a list of lexical tokens
function lextokens(src; rmacc = true)
    c = CitableCorpus.fromfile(CitableTextCorpus,f)
    lextokens = []
    for cn in c.corpus
        tokenlist = PolytonicGreek.tokenizeLiteraryGreek(cn.text)
        for t in tokenlist
            if (t.tokencategory ==  Orthography.LexicalToken())
                rmacc ? push!(lextokens, rmaccents(t.text)) : push!(lextokens, t.text)
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



function propidx(arr, i, n = 1)
    proptotal = arr[1:n] |> sum
    if proptotal > i
        n
    else
        propidx(arr, i, n + 1)
    end
end

function runningtotals(arr)
    runningtotalarr = []
    for i in 1:length(arr)
        push!(runningtotalarr, sum(arr[1:i]))
    end
    runningtotalarr
end

# Triples of token, proportion, running total of proportion
trips =  zip(tokenlist, arr, runningtotals(arr)) |> collect


# Compute proportion of tokens covered by tokens occurring
# n or more times
function occurenceproportion(histo, n)
    arr = histo.array
    finalidx = 0
    revidx = for i in 1:length(arr)
        if arr[i] >= n
            #print(arr[i], " >= ", )
            finalidx = i
        end
    end
    proportions = prop(histo)
    proportions[1:finalidx] |> sum
end