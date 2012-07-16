function [ output_args ] = write_coordinates( pdbId, mode )
load([pdbId '.mat'])

if strcmp(mode,'dR')
    fid = fopen([pdbId '_dR.dat'], 'w');
    for r=1:size(obj.displacements ,2)
        for c=1:size(obj.displacements ,1)
            fprintf(fid, '%12.8f ', obj.displacements(c,r));  
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

if strcmp(mode,'dr')
    obj.modalCoordinates(end-6+1:end,:) = []; % Remove global movements

    artifacts = [];
    for i=1:size(obj.modalCoordinates,1)
        art = find(obj.modalCoordinates(i,:)>4); %threshold for deviation. 
        if(~isempty(art))
            artifacts = union(artifacts, art);
        end
    end
    obj.modalCoordinates(:,artifacts) = []; % Remove artifacts
    obj.displacements(:,artifacts) = [];
    fprintf('Warning: There are %d artifact frame exist\n',length(artifacts));
    
    fid = fopen([pdbId '_dr.dat'], 'w');
    for r=1:size(obj.modalCoordinates ,2)
        for c=1:size(obj.modalCoordinates ,1)
            fprintf(fid, '%12.8f ', obj.modalCoordinates(c,r));  
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

    
end

