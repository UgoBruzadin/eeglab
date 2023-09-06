%detectaveragefiles

files = dir('*.set');

mkdir('Error');
cd('./Error');
fileERROR = pwd;
cd ..

mkdir('REDO');
cd('./REDO');
fileREDO = pwd;
cd ..


parfor i=1:size(files,1)
try
[EEG] = pop_loadset('filename',files(i).name,'filepath',pwd);

if strcmp(EEG.chanlocs(1).ref,'average')

    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0}));
    EEG = pop_reref( EEG, 86);
    EEG = pop_saveset(EEG, 'filename', [files(i).name(1:10),'_fixedref.set'], 'filepath',  fileREDO ); %save set
end
catch
    movefile(files(i).name, fileERROR);
end
end