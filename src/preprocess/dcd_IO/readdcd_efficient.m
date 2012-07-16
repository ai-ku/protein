
function xyz = readdcd_efficient(filename, ind)

% xyz = readdcd(filename, indices)
% reads an dcd and puts the x,y,z coordinates corresponding to indices 
% in the rows of x,y,z

h = read_dcdheader(filename)
nsets = h.NSET;
natoms = h.N;
numind = length(ind);

%x = zeros(natoms,1);
%y = zeros(natoms,1);
%z = zeros(natoms,1);

start = 0;
finish = nsets;
ans = input('Do you wanna select dcd frames? y or n\n','s');
if (ans == 'y')
    s = input('f x l x\n','s');
    r=regexp(s,' ','split');
    for i=1:length(r)-1
       if r{i} == 'f'
          start = str2num(r{i+1}); 
       end
       if r{i} == 'l'
          finish = str2num(r{i+1});  
       end
    end
end

if nsets == 0
  xyz = zeros(1,3*numind);
  nsets = 99999;
else
  xyz = zeros(finish-start, 3*numind);
end

for i=1:finish
  pos = ftell(h.fid);
  if pos == h.endoffile 
    break;
  end
  
  %[x,y,z] = read_dcdstep_efficient(h,ind);
  [x,y,z] = read_dcdstep(h);
  if i > start
      xyz(i-start,1:3:3*numind) = x';
      xyz(i-start,2:3:3*numind) = y';
      xyz(i-start,3:3:3*numind) = z';
  end
end

close_dcd(h);

