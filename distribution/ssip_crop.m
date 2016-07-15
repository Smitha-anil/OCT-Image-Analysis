
function [] =ssip_crop(folderName)
inputDir=folderName;
%Type of file to search for
filePattern = fullfile(inputDir, '*.png');

%List folder content
f=dir(filePattern)
files={f.name}

%Create the output folder
if exist('output','dir')
    rmdir('output','s');
end
mkdir('output');

%Read each file from the inputDir and crop the region of the interest and
%write the images to the output folder
for k=1:numel(files)
    Im{k}=imread(files{k});
    file=Im{k};
    imageFile=file(:,:,1);
    processedImage{k} =im2double(imcrop(imageFile,[500 0 498 450]));
    outputFile=strcat('output\image_',num2str(k),'.tif');
    imwrite(processedImage{k},outputFile)
end

% I = imread('C:\Users\padideh\Desktop\project\seq_09_1\Seq_09_1_img_01.png');
% I2 = imcrop(I,[495 0 498 498]);
% I3{1}=I2
%figure, imshow(m2{23})
end