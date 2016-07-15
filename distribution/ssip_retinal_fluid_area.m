function [featureVector] =ssip_retinal_fluid_area(imageName, number)

LEVEL_THRESHOLD_CORRECTION1=.16;
LEVEL_THRESHOLD_CORRECTION2=.2;
SMALL_AREA_SIZE1=200;
SMALL_AREA_SIZE2=10;



%read the image and get properies
img = imread(imageName);
imageSize=size(img);


%% Pre-processing
%get the center of the image
locationX=imageSize(1,1)/2;
locationY=imageSize(1,2)/2;

figure, imshow(img);
title('Original input image');

%enhance image contrast
img = imadjust(img,[0,0.9],[0 1]);
%figure; imshow(img);

%apply median filter to remove salt-peper noise
img=medfilt2(img);
%figure; imshow(img);

%% Binarization

%Threshold level estimation
thresholdLevel= graythresh(img);


%Binarize the image using corrected threshold 
imgBW=im2bw(img,thresholdLevel+LEVEL_THRESHOLD_CORRECTION1);
%figure;imshow(imgBW);

%% Mask creation

%Fill image regions and holes
imgBW1 = imfill(~imgBW,'hole');
%figure; imshow(imgBW1);

%Remove small size area 
imgBW2= bwareaopen(imgBW1,SMALL_AREA_SIZE1);
%figure, imshow(imgBW2);



%% Segmentation

%Thresholding 
thresholdLevel2 = graythresh(img);
correctedThreshold=thresholdLevel2+LEVEL_THRESHOLD_CORRECTION2;

if(correctedThreshold>1)
    correctedThreshold =1;
end

imgBWS=im2bw(img,correctedThreshold);
%figure;imshow(imgBWS);

% Overlaying the images to see the difference 
% imfusedImg = imfuse(img,imgBWS);
% figure, imshow(imfusedImg);


imgBWS1= bwareaopen(imgBWS,SMALL_AREA_SIZE2);

%figure;imshow(imgBWS1);

%apply mask to remove background 
imgBWS1=imgBWS1.*imgBW2;

%% Labeling 

labeledImage=bwlabel(imgBWS1);
%figure; imshow(labeledImage);

% Get image features
featureVector=regionprops(labeledImage,'Area','MajorAxisLength','Eccentricity','Orientation','Perimeter','Centroid');

area1=[ ];
for vv=1:size(featureVector)
    if(featureVector(vv).Centroid(1,1)<locationX)
        index=find(labeledImage==vv);
        labeledImage(index) = 0;
    end
    
    
    area1 = [area1,featureVector(vv).Area];
    
   
end

%figure, imshow(labeledImage);

% %%  Spliting the sub-retina from cysts
% featureVector= regionprops(labeledImage,'Area','MajorAxisLength','Eccentricity','Orientation','Perimeter','Centroid');
% 
% f1=labeledImage-labeledImage;
% 
% f2=labeledImage-labeledImage;
% 
% area1=[ ];
% for vv=1:size(featureVector)
%     if(featureVector(vv).Area<50 && featureVector(vv).Area>10)
%         index=find(labeledImage==vv);
%         f1(index) = 1;
%     end
%     
%     if(featureVector(vv).Area>50)
%         index=find(labeledImage==vv);
%         f2(index) = 1;
%     end
%     
%     
% end

%figure,imshow(f1);


outputFile=strcat('results\image_',number);

resultsImage = imoverlay(img,labeledImage,'red');
% resultsImage = imoverlay(img,f1,'red');
% resultsImage = imoverlay(resultsImage,f2,'cyan');
fig=figure;
subplot(2,1,1);imshow(img);title('Original')
subplot(2,1,2);imshow(resultsImage); title('Labeled')
print(fig,outputFile,'-dpng')

end



%getRetinalLayers(img)

