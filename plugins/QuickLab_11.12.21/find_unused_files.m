function unusedfilelist = find_unused_files(gateway_fcn)
% FIND_UNUSED_FILES gateway_fcn
%   gateway_fcn is a char with the function name.
%
% FIND_UNUSED_FILES checks all files in the same directory as the 
% gateway_fcn, including subdirectories. It then prints a list of files
% that are not called by the gateway function.
%
% Example: find_unused_files('foo') will call the function foo and print a
% list of files that are not called by the foo function.
%
% Hannes Mogensen, Lund University
unusedfilelist = [];

if ~ischar(gateway_fcn)
  error('Input function must be a char array')
end

search_path = which(gateway_fcn);
top_dir = fileparts(search_path);

dependent_files = matlab.codetools.requiredFilesAndProducts(gateway_fcn);
all_files = dir([top_dir filesep '**' filesep '*.m']);



for k=1:numel(all_files)
  file = all_files(k).name;
 
  if ~nnz(cellfun(@(x) strcmp(x, file), dependent_files));
    %fprintf('%s\n',all_files(k).name);
    unusedfilelist = [unusedfilelist,[file]];
  end
end

end