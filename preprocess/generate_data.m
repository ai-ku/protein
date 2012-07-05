function [ obj ] = generate_data( pdbId, mode, sFrame, eFrame)
%function generate_data( pdbId, mode)
%GENERATE_DATA Generates important files of protein
%   This function creates covariance matrix, displacement, modalcoordinates
%   etc.
obj.mode = ''; 
if nargin < 4
   if nargin < 3
      sFrame = '1' ;
      if nargin < 2
        obj.mode = ''; 
        obj.sampling = 10; % Hardcoded train-test split ratio
      else
        obj.mode = mode;
      end
   end
   eFrame = '99999';
end

%% Read PDB
[u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13]=textread([pdbId '.pdb'],'%s %s %s %s %s %s %s %s %s %s %s %s %s');
            
l=1;nA=0;
for i=1:length(u1)
    if strcmp('ATOM',u1(i))
        nA=nA+1;%Number of atom
    end
    if strcmp('CA',u3(i))
        names{l} = u4{i};
        rn(l) = str2num(u6{i});
        m(l)=nA;%Index of the l th CA atom
        indices(l) = str2num(u6{i});
        if length(str2num(u11{i})) > 0
            B(l) = str2num(u11{i});
        else
            B(l) = 100.0;
        end
        l=l+1;
    end
end
obj.Aminoacids = names;
obj.Bfactors = B;
obj.ResidueNumber = rn;
obj.Calfas = m;
obj.Natoms = nA;
obj.index2id = indices;
clear u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13

%% Read DCD file
addpath('dcd_IO');
%obj.dcddata = readdcd_efficient([pdbId '.dcd'],obj.Calfas);
obj.dcddata = readdcd([pdbId '.dcd'],obj.Calfas);
if str2num(sFrame) > 1 || str2num(eFrame) ~= 99999
    obj.dcddata = obj.dcddata(str2num(sFrame):str2num(eFrame),:);
end
 
if(strcmp(obj.mode,'train'))
   obj.dcddata(1:obj.sampling:end,:) = []; 
end
if(strcmp(obj.mode,'test'))
   obj.dcddata = obj.dcddata(1:obj.sampling:end,:);
end

nFrames=size(obj.dcddata,1); %Number of time frames
obj.Nframes = nFrames;
%disp(nFrames)
nC = size(obj.dcddata,2)/3;
% Mean Coordinates and deltaR
% Initializing coordinates and mean value matrices
x=zeros(nC,1); xm=zeros(nC,1);
y=zeros(nC,1); ym=zeros(nC,1);
z=zeros(nC,1); zm=zeros(nC,1);

for f=1:nFrames 
    % getting x,y,z coordinates for the f`th frame 
    for i=1:nC
        xm(i)=xm(i)+obj.dcddata(f,3*(i-1)+1)/nFrames;
        ym(i)=ym(i)+obj.dcddata(f,3*(i-1)+2)/nFrames;
        zm(i)=zm(i)+obj.dcddata(f,3*(i-1)+3)/nFrames;
    end
end

RF=zeros(3*nC,3*nC); %Covariance Matrix
Rall=zeros(3*nC,length(1:nFrames)); %Coordinate matrix
mRall= [xm,ym,zm]; %Mean coordinates 
obj.meanCoords = mRall;
for f=1:nFrames 
    % Getting x,y,z coordinates for the f`th frame and transforming them into dx dy dz
    for i=1:nC
        x(i)=-xm(i)+obj.dcddata(f,3*(i-1)+1);
        y(i)=-ym(i)+obj.dcddata(f,3*(i-1)+2);
        z(i)=-zm(i)+obj.dcddata(f,3*(i-1)+3);   
    end

    %Constructing dR vector
    r12 = [x; y; z]';
    
    %Constructing dR' vector
    r11=r12';

    %Constructing matrix of all real coordinates
    Rall(:,f)=r11; % Fluctiations

    % Adding previouse elements to the current elements to calculate the covariance matrix
    RF=RF+(r11*r12)/nFrames;
end
obj.covarianceMatrix = RF;
% Real fluctuations in time for different residuals
for i=1:nC
    RR(i,:)=(Rall(i,:).^2 + Rall(nC+i,:).^2 + Rall(2*nC+i,:).^2).^.5;
end
obj.distances = RR;

%% Mode analysis
RF = obj.covarianceMatrix;
nC = size(RF,1)/3;

[V,D] = eigs(RF,3*nC);
obj.eigVals = D;
obj.eigVecs = V;

ze=0; %Number of zero eigenvalues
% Determining zero eigenvalues and ignoring them for the transformation into the mode space
for g=1:size(D)
    if D(g,g) > 10^-8%eps
%         if g<size(D)-4
        D2(g,g)=1/(D(g,g))^0.5;
        D3(g,g)=(D(g,g))^0.5;
    else
        ze=ze+1;
        D2(g,g)=0;
        D3(g,g)=0;
    end
end

D=sparse(D);
D2=sparse(D2);
D3=sparse(D3);

RFO=D2*V';
obj.RT = RFO;
% RFO=RF^-0.5  
m = obj.Calfas;

xm=zeros(nC,1); ym=zeros(nC,1); zm=zeros(nC,1);
nFrames = obj.Nframes;
for f=1:nFrames 
    % getting x,y,z coordinates for the f`th frame 
    for i=1:nC
        xm(i)=xm(i)+obj.dcddata(f,3*(i-1)+1)/nFrames;
        ym(i)=ym(i)+obj.dcddata(f,3*(i-1)+2)/nFrames;
        zm(i)=zm(i)+obj.dcddata(f,3*(i-1)+3)/nFrames;
    end
end
drall=zeros(3*nC,length(1:nFrames));
% Getting coordinates in Mode Space
for f=1:nFrames
    % getting x,y,z coordinates for the f`th frame 
    for i=1:nC
        x(i)=-xm(i)+obj.dcddata(f,3*(i-1)+1);
        y(i)=-ym(i)+obj.dcddata(f,3*(i-1)+2);
        z(i)=-zm(i)+obj.dcddata(f,3*(i-1)+3);
        r(i)=sqrt(x(i)^2+y(i)^2+z(i)^2);
    end
    r12 = [x; y; z];
    
    %Projection on Mode Space
    dr=RFO*r12;

    %all modal coordinate values dr over time
    drall(:,f) = dr;
    displacements(:,f) = r12;
end
obj.displacements = displacements;
obj.modalCoordinates = drall;

%% Save structure
save([pdbId '.mat'],'obj');
end

