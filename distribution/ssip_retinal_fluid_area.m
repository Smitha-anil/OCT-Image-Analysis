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

%%  Spliting the sub-retina from cysts
 
 
 x2=img-img;
 idxx=find(img<100);
 x2(idxx)=img(idxx)*170;
 figure;imshow(x2);
 x21=bwmorph(x2,'thin',10);
 figure;imshow(x21);
%  

 dist=bwdist(x21);
 figure;imshow(dist);
 STS= regionprops(f,'Area','MajorAxisLength','MinorAxisLength','Centroid');
 distx=dist-dist;
 dist1(1:194,1:499)=dist(1:194,1:499);
 dist1(195:450,1:499)=distx(195:450,1:499)
 figure;imshow(dist1);
 
  dist2(1:194,1:499)=distx(1:194,1:499);
 dist2(195:450,1:499)=dist(195:450,1:499)
 figure;imshow(dist2)
 
% dist1=imcrop(dist,[0 0 498 194]);
% figure;imshow(dist1)
% SizeD1=size(dist1);
% dist2=imcrop(dist,[0 194 498 194]);
% SizeD2=size(dist2);
% figure;imshow(dist2);
 % f1 cyst
 %f2  subretinal 
f1=labeledImage-labeledImage;
f2=labeledImage-labeledImage;
area1=[ ];
 for vv=1:size(STS)
        
     CenterX=STS(vv).Centroid(1,1)
     CenterY=STS(vv).Centroid(1,2)
     if (~isnan(CenterX) && ~isnan(CenterY))
       if(dist1(floor(CenterY),floor(CenterX)) ~=0)
   if(dist1(floor(CenterY),floor(CenterX)) <= STS(vv).MajorAxisLength/2+10)
    idx3=find(f==vv);
    f1(idx3) = vv;
   end
       end
       if(dist2(floor(CenterY),floor(CenterX)) ~=0)
   if (dist2(floor(CenterY),floor(CenterX)) <= (STS(vv).MajorAxisLength/2))
    idx3=find(f==vv);
    f2(idx3) = vv;
   end
       end
     end
 end
 
figure,imshow(f-f2);title('cyst');
figure;imshow(f2);title('Subretinal Fluid');
tt=imfuse(f1,f2);
ttt=imfuse(tt,img);
figure;imshow(ttt);


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

