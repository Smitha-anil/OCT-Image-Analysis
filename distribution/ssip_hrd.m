function [] =ssip_hrd(imageName, number)

LEVEL_THRESHOLD_CORRECTION1=.1;
SMALL_AREA_SIZE1=200;
R1=50;
N1=0;
R2=50;
N2=90;
MIN_AREA_SIZE=1;
MAX_AREA_SIZE=300;


img = imread(imageName);
%figure, imshow(img);

% %create inverted image
% img1=imcomplement(img);
% figure, imshow(img1);


%% mask

%Estimation of threshold
thresholdLevel1 = graythresh(img);
correctedThreshold=thresholdLevel1+LEVEL_THRESHOLD_CORRECTION1;

if(correctedThreshold>1)
    correctedThreshold =1;
end

imgBW=im2bw(img,correctedThreshold);
%figure;imshow(imgBW);

imgBW1 = imfill(imgBW,'hole');
imgBW1 = imfill(~imgBW1,'hole');
%figure; imshow(imgBW1);

imgBW2= bwareaopen(imgBW1,SMALL_AREA_SIZE1);
%figure; imshow(imgBW2);

%Create morphological structuring element to decrease the size region of
%the interest
se1 = strel('line',R1,N1);
se2 = strel('line',R2,N2);
imgBW2 = imerode(imgBW2,[se1,se2]);
%figure;imshow(imgBW2)


%% detecting HRD

%apply mask to the image
x=im2double(img).*imgBW2;
%figure;imshow(x);

%% Selecting HRD points based on the intensity from the original image
x2=x-x;
index=find(x<0.2);
x2(index)=x(index)*100;
%figure;imshow(x2);

%% Labeling

labeledImage=bwlabel(x2);
%figure; imshow(labeledImage);

featureVector= regionprops(labeledImage,'Area','MajorAxisLength','Eccentricity','Orientation','Perimeter','Centroid');
f2=labeledImage-labeledImage;

%large spots removal
for vv=1:size(featureVector)
    if(featureVector(vv).Area>MIN_AREA_SIZE && featureVector(vv).Area<MAX_AREA_SIZE)
        idx3=find(labeledImage==vv);
        f2(idx3) = 1;
    end
    
end

%figure, imshow(f2);

%% Altering labeling presentation to show only contours
%g=f2.*im2double(img);
%figure;imshow(g);


%resultsImage = imoverlay(img,f2,'red');
outputFile=strcat('results_hrd\image_',number);
fig=figure;
subplot(2,1,1);imshow(img);title('Original')
subplot(2,1,2);imshow(img); title('Labeled')
B = bwboundaries(im2double(f2),'noholes');
%figure;imshow(img)
hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
print(fig,outputFile,'-dpng')
end

