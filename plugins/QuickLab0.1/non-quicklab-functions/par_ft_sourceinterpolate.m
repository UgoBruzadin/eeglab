function source_int = par_ft_sourceinterpolate(cfg,source,atlas_int)
isworker = getCurrentWorker();
    
currentFunction = mfilename;
fprintf('Currently running: %s\n', currentFunction);% Print the name of the currently running function

source_ints = repmat(struct('sources',[]), length(source.freq), 1);

if ~isempty(isworker)
    for j=1:size(source_ints,1)
        individual_source = source;

        try individual_source.avg.pow = source.avg.pow(:,j);catch; end
%         try individual_source.avg.mom = source.avg.mom(:,j);catch; end
%         try individual_source.pow = source.pow(:,j);catch; end
%         try individual_source.mom = source.mom(:,j);catch; end

        source_ints(j).sources      = ft_sourceinterpolate(cfg, individual_source, atlas_int);
    end
else
    parfor j=1:size(source_ints,1)
        individual_source = source;
        try individual_source.avg.pow = source.avg.pow(:,j);catch; end
%         try individual_source.avg.mom = source.avg.mom(:,j);catch; end
%         try individual_source.pow = source.pow(:,j);catch; end
%         try individual_source.mom = source.mom(:,j);catch; end
        source_ints(j).sources      = ft_sourceinterpolate(cfg, individual_source, atlas_int);
    end
end

source_int = source_ints(1).sources;
for k=2:length(source.freq)
    source_int.pow = cat(2,source_int.pow,source_ints(k).sources.pow);
end
source_int.powdimord = 'pos_freq';

end
