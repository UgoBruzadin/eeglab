function newSortedArray = sortArray(Array)

    SortArray = Array;
    
    % -- sorts the correlations in descending order
    [SortCorrs, CorOrder] = sort(SortArray, 'descend');
    
    % -- resorts the components according to the new sorting of the correlations
    % --  makes a new variable called newSortedComps containing
    % -- the components in a sorted fashion
    newSortedArray = [];
    for n=1:length(SortArray)
        newSortedArray(n) = SortArray(CorOrder(n))
    end    
end