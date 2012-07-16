function [ output_args ] = dr2dR( pdbId, drfile )
%DR2DR Summary of this function goes here
%   Detailed explanation goes here
dr = importdata(drfile);
load([pdbId '.mat']); 
%[V,D] = eigs(obj.covarianceMatrix,size(obj.covarianceMatrix,1));
%dr2dR = V*(D^.5); 
dr2dR = obj.eigVecs*(obj.eigVals^.5);

for i=1:size(dr,1)
   dR(i,:) = dr2dR*[dr(i,:) zeros(1,6)]';
end

filename = strrep(drfile,'dr','dR'); % Change name

fid = fopen(filename, 'w');
for r=1:size(dR,1)
    for c=1:size(dR,2)
        fprintf(fid, '%12.8f\t', dR(r,c));  
    end
	fprintf(fid, '\n');
end
fclose(fid);

end

