% 
%     {{}}
%     
% 


%% Pre-processing step
close all; clear all; clc;
%Data set preparation
ssip_crop('C:\Users\somebody\Downloads\OCT-Image-Analysis-master\OCT-Image-Analysis-master\distribution\images\seq_09_1');
%featureVector=ssip_retinal_fluid_area('C:\Users\somebody\Downloads\output\image_22.tif');
% ssip_hrd('C:\Users\somebody\Downloads\output\image_22.tif',num2str(1));

inputDir='C:\Users\somebody\Downloads\OCT-Image-Analysis-master\OCT-Image-Analysis-master\distribution\output';

if exist('results','dir')
    rmdir('results','s');
end
mkdir('results');

if exist('results_hrd','dir')
    rmdir('results_hrd','s');
end
mkdir('results_hrd');
%Type of file to search for
filePattern = fullfile(inputDir, '*.tif');



%List folder content
f=dir(filePattern)
files={f.name}
for k=1:numel(files)
    
    featureVector=ssip_retinal_fluid_area(strcat('C:\Users\somebody\Downloads\output\image_',num2str(k),'.tif'),num2str(k));
    %ssip_hrd(strcat('C:\Users\somebody\Downloads\OCT-Image-Analysis-master\OCT-Image-Analysis-master\distribution\output\image_',num2str(k),'.tif'),num2str(k));
    
    %     processedImage{k} =im2double(imcrop(imageFile,[500 0 498 450]));
%     outputFile=strcat('output\image_',num2str(k),'.tif');
%     imwrite(processedImage{k},outputFile)
end
