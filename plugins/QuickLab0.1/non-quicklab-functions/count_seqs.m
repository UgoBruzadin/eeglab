function sequences = count_seqs(array,value)

sequences = [];

values = array == value;

notvalues = ~array;

notvalueInd = find(notvalues);

for i=1:size(notvalueInd,2)+1
    nextseq = sum(values(i))
    sequences = sequences


end


end