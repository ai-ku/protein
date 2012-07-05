function manipulate_dcd(params)
% Manipulates the DCD files. Merges and splits given files.
% MANIPULATE_DCD(params)
% USAGE:
%   Parameters:
%       - 'first'  determines first frame of DCD file. (Default 1)
%       - 'last'   determines last frame of DCD file.
%       - 'sample' determines sampling rate of frames. (Default 1)
%       - 'output' output filename. (Default temp.dcd)
%       - 'inputs' input files. This field must be at the end.
%
%   manipulate_dcd({'output', 'p_all.dcd', 'first', 1000, 'last', 5000,
%                  'sample', 10, 'inputs' ,'p_1.dcd', 'p_2.dcd'});

first = 1;
lastt = 99999;
output = 'temp.dcd';
sample = 1;
%% Read Inputs
for i=1:length(params)
   if strcmp(params{i},'first')
       first = params{i+1};
   end
   if strcmp(params{i},'last')
       lastt = params{i+1};
   end
   if strcmp(params{i},'sample')
       sample = params{i+1};
   end
   if strcmp(params{i},'output')
       output = params{i+1};
   end
   if strcmp(params{i},'inputs') || strcmp(params{i},'input')
       for j=i+1:length(params)
           inputs{j-i} = params{j};
       end
   end
end

%% Read input DCD
h = read_dcdheader(inputs{1});
%% Merge 
if length(inputs) > 1
    
end
%% Write new DCD
nsets = h.NSET;
if h.NSET == 0
  nsets = 99999;
end

newFrame = 1;
for i=1:sample:nsets
  pos = ftell(h.fid);
  if pos == h.endoffile 
    break;
  end
  [x,y,z] = read_dcdstep(h);
  if (i >= first) && (i <= lastt)
      xx(newFrame,:) = x;
      yy(newFrame,:) = y;
      zz(newFrame,:) = z;
      newFrame = newFrame + 1;
  end
end
close_dcd(h);

[nsets, natoms] = size(xx);
g = write_dcdheader(output, nsets, natoms);
for i=1:nsets
  rc = write_dcdstep(g, xx(i,:)', yy(i,:)', zz(i,:)');
end
close_dcd(g);
end