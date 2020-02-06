a = []

%corr(ALLEEG(6).icawinv(:,1),ALLEEG(24).icawinv(:,1))

for i=1:length(ALLEEG)
    for j=1:size(ALLEEG(i).icaweights,1)
        for k=1:length(ALLEEG(k).icaweights,1)
            a(end+1) = corr((ALLEEG(i).icaweights,1),(ALLEEG(k).icaweights,1));
        end
    end
end