function parsave(name, variable, flag)

  string = inputname(2);
  if strcmp(string,'dataFreq')
      dataFreq = variable;
      save(name, 'dataFreq', flag)
  elseif strcmp(string,'source')
      source = variable;
      save(name, 'source', flag)
  elseif strcmp(string,'source_int')
      source_int = variable;
      save(name, 'source_int', flag)
  end
end