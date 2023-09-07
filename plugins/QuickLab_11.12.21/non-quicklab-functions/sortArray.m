function newSortedArray = sortArray(Array)

    SortArray = Array;
    
    % -- sorts the correlations in descending order
    [SortCorrs, ArrayOrder] = sort(SortArray, 'descend');
    
    % -- resorts the components according to the new sorting of the correlations
    % --  makes a new variable called newSortedComps containing
    % -- the components in a sorted fashion
    newSortedArray = zeros(size(Array,2),1);
    for n=1:length(SortArray)
        newSortedArray(n) = SortArray(ArrayOrder(n));
    end    
end