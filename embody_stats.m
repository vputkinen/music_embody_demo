%% This is a demo of how to efficiently run a one sample ttest
% for a set of preprocessed subjects

% Original code by Enrico Glerean and Lauri Nummenmaa
% Modified by Vesa Putkinen for running the demo on the example data 
% from Putkinen et al. 2023

clear all
close all

%% mask (we consider only pixels inside the mask for multiple comparisons)
mask = rgb2gray(imread('auxiliary/mask_600.png'));
in_mask = find(mask);

%% load all subjects
basepath='data/preprocessed';
files=dir(fullfile(basepath,'*.mat')); % preprocessed files, obtained by embody_png2mat.m
NS=length(files);
NC=2; % number of conditions
data=zeros(length(in_mask),NS,NC);

for s=1:NS
    load(fullfile(basepath,files(s).name)); % now we have variable resmat
    % reshape 3D matrix intro 2D matrix ( pixels X conditions )
    temp=reshape(resmat,[],NC);
    data(:,s,:)=temp(in_mask,:);
end

tdata=zeros(length(in_mask),NC);
for condit=1:NC
    [H,P,CI,STATS] = ttest(data(:,:,condit)');
    tdata(:,condit)=STATS.tstat;
end

%% multiple comparisons correction across all conditions
alltdata=tdata(:);

df=NS-1;    % degreeso of freedom
P        = 1-cdf('T',alltdata,df);  % p values
[pID pN] = FDR(P,0.05);             % BH FDR
tID      = icdf('T',1-pID,df);      % T threshold, indep or pos. correl.
tN       = icdf('T',1-pN,df) ;      % T threshold, no correl. assumptions

%% plot tmaps

M=10; % max range for colorbar
NumCol=100;

th=tID; % if tID is null, you need to use an uncorrected T-value threshold.
if(isempty(th))
    % using uncorrected T-value threshold
    th=3;
end

non_sig=round(th/M*NumCol); % proportion of non significant colors
hotmap=hot(NumCol-non_sig);

% reshaping the tvalues into images
tvals_for_plot=zeros(size(mask,1),size(mask,2),NC);
for condit=1:NC
    temp=zeros(size(mask));
    temp(in_mask)=tdata(:,condit);
    temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
    max(temp(:))
    tvals_for_plot(:,:,condit)=temp;
end

% plotting
plotcols = 3; %set as desired
plotrows = ceil((NC+1)/plotcols); % number of rows is equal to number of conditions+1 (for the colorbar)
base2=uint8(imread('auxiliary/dummy_600.png'));
labels={
    'Happy'
    'Sad'
    };

figure()
hold on;

for n=1:NC    
    subplot(plotrows,plotcols,n)
    imagesc(base2);
    axis('off');
    set(gcf,'Color',[1 1 1]);
    over2=tvals_for_plot(:,:,n);
    fh=imagesc(over2,[0,M]);
    axis('off');
    axis equal
    colormap(hotmap);
    set(fh,'AlphaData',mask)
    title(labels(n),'FontSize',10)
    if(n==NC)
        subplot(plotrows,plotcols,n+1)
        fh=imagesc(ones(size(base2)),[0,M]);
        axis('off');
        colorbar;
    end
end

hold off




