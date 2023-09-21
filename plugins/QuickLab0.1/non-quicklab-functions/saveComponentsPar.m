function saveComponentsPar(EEG)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

if isempty(EEG.icaact)
    fprintf('No ICA, run ICA /r');
    return
end

%if isfile('corrmappath.txt')
    corrmappath = readtext('corrmappath.txt');
    if iscell(corrmappath)
        corrmappath = corrmappath{:};
    end
%end
myComps = find(EEG.reject.gcompreject);

if ~myComps
    fprintf('No component selected, select components first /r');
    EEG = pop_fastIClabel(EEG);
    return
end
try 
    cd(corrmappath)
catch corrmappath = savecorrmappath()
    cd(corrmappath)
end


chanfolder = num2str(EEG.nbchan);

mkdir(chanfolder);

cd(strcat('./',chanfolder));

corrmapFiles = dir('*.set');

EEGbase = EEG;

EEGbase = pop_iclabel(EEGbase);

myComps = find(EEGbase.reject.gcompreject);   %stores the Id of the components to be rejected
if myComps
    parfor i = 1:length(myComps)
        % --- Get all component numbers
        allComps = [1:size(EEGbase.icawinv,2)];
        % --- remove the one component number
        allComps(i) = [];
        % --- make another copy of the EEG data
        EEGComp = EEGbase;
        % --- removes the other components from the data-set to minimize file
        % ---- size
        EEGComp = pop_subcomp(EEGComp, allComps, 0);       % actually removes the flagged components
        % --- get number and value of the component classification
        [value,col] = max(EEGbase.etc.ic_classification.ICLabel.classifications(myComps(i),:));
        % --- start the name of the component with it's classification
        corrName = EEGbase.etc.ic_classification.ICLabel.classes(col);
        corrName = corrName{:}; % --- removes it from a cell into a str/char
        % --- get number of components in the list; start fresh if list of components is empty
        if isempty(corrmapFiles)
            compNumber = 1;
        else
            compNumber = size(corrmapFiles,2) + i;
        end
        % --- finalize component name with %, number and ID
        corrName = strcat(corrName,'-',num2str(compNumber),'-',num2str(value));
        % --- save component
        pop_saveset(EEGComp, 'filename', [strcat(corrName, '.set')],'filepath',pwd);
    end
end
end