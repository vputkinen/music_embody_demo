% The code resamples png images obrained with the emBODY tool in Gorilla to 
% 600 X 205 pixels and saves them as mat files which can be used in statisical 
% analysis with embody_stat.m script. 
%
% The data were obtained in an experiment where subjects listened to sad and happy 
% music and indicated the body regions whose activity they felt changing 
% while listening  

% Code by Vesa Putkinen

clear; clc;

% directory containing the png images downloaded from Gorilla
input_dir = 'data/png';

% extract subject ids from png file names
files = dir(fullfile(input_dir, '*png'));
temp = cellfun(@(x) strsplit(x,'-'), {files.name}, 'un',0);
ids = unique(cellfun(@(x) x{3},temp,'un',0));

% target dimensions for the resampled images
target_dim = [600, 205];
h=fspecial('gaussian',[15 15],5);

for i_id = 1:length(ids)
    
    id = ids{i_id};
    images = dir(fullfile(input_dir,['*',id,'*']));
    images = fullfile({images.folder},{images.name});
    
    n = length(images);
    resmat = zeros(target_dim(1), target_dim(2), n);
    for i_img = 1:n
        
        img = imread(images{i_img});
        map = (img(:,:,1) == 255) & (img(:,:,2) == 0) & (img(:,:,3) == 0);
        map = double(map);
        
        % Resample image
        source_dim = size(map);
        [X,Y] = meshgrid(linspace(1,source_dim(2),target_dim(2)), ...
            linspace(1,source_dim(1),target_dim(1)));
        map_interp = interp2(map,X,Y);
        map_interp(map_interp > 0) = 1;
        
        map_interp_s = imfilter(map_interp,h);
        
        resmat(:,:,i_img) = map_interp_s;
    end
    
    save(fullfile('data/preprocessed', [id, '_preprocessed.mat']), 'resmat');
end