function filelist = GetSpecificFiles(files,marker)

filelist = files(~cellfun(@isempty,regexp({files.name}, marker)));

end