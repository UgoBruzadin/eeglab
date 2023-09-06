

B = empty(size(FILES,2,1))

for i=1:size(FILES,2)

    B = FILES(i,2)
    C = B{:}
    D = mean(C)
    
end