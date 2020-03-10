jpegFiles = dir('*.jpg'); 
numfiles = length(jpegFiles);
mydata = cell(1, numfiles);

for t = 158
  mydata{t} = imread(jpegFiles(t).name); 
dim = size(mydata{t});
% Change input image to gray scale
leng = length(dim);
if leng == 3
    mydata{t} = rgb2gray(mydata{t});
end
mydata{t}=imgaussfilt(mydata{t},6);
subplot(2,3,1);
imshow(mydata{t});
title('Original Image');
subplot(2,3,2);
imshow(mydata{t});
title('Blurred Image');
% histgram of input image
ihis = imhist(mydata{t});
leng = length(ihis);
para = zeros(1,leng);
for k = 2:leng-1
    % intensity of class A
    classa = ihis(1:k);
    ind = (classa==0);
    classa = classa+ind;
    clear ind
    % intensity of class B
    classb = ihis(k+1:end);
    ind = (classb==0);
    classb = classb+ind;
    clear ind
    % probability distribution of class A
    Pa = classa/(dim(1,1)*dim(1,2));
    % probability distribution of class B
    Pb = classb/(dim(1,1)*dim(1,2));
    % parameters to decide threshold
    para1 = log2(sum(Pa));
    para2 = log2(sum(Pb));
    logpa = log2(Pa);
    logpb = log2(Pb);
    para3 = -sum(Pa.*logpa)/sum(Pa);
    para4 = -sum(Pb.*logpb)/sum(Pb);
    % parameter which has to be maximized
    para(1,k) = abs(para1+para2+para3+para4);
    clear classa classb logpa logpb
end
% find threshold
[maxv,row] = max(para);
thresh = row-1;
% segment input image
newFilt = (mydata{t}>=thresh);
subplot(2,3,3);
imshow(newFilt);
title('Thresholding');
numberExtract=1;
[labeledImage,numberofB]=bwlabel(newFilt);
stats=regionprops(labeledImage,'Area');
allAreas=[stats.Area];
[sortedAreas,sortIndices]=sort(allAreas,'descend');
biggestBlob=ismember(labeledImage,sortIndices(1:numberExtract));
binaryImage=biggestBlob>0;
BW=bwmorph(binaryImage,'close');
BW=bwmorph(BW,'fill');
BW=imfill(BW,'holes');
subplot(2,3,4);
imshow(BW);
title('Tumor');
BWoutline = bwperim(BW,18); % find perimeter of tumor in binary image
C=imfuse(BWoutline,mydata{t});
subplot(2,3,5);
imshow(C);
title('Segmented Image'); 
wpbFeatures = regionprops(BW, 'Area','Centroid', 'MajorAxisLength', 'MinorAxisLength', 'Eccentricity', 'EquivDiameter');
wpbArea = vertcat(wpbFeatures.Area);
wpbCentroid = vertcat(wpbFeatures.Centroid);
wpbCentroidX = wpbCentroid(:,1);
wpbCentroidY = wpbCentroid(:,2);
wpbMajorAxisLength = vertcat(wpbFeatures.MajorAxisLength);
wpbMinorAxisLength = vertcat(wpbFeatures.MinorAxisLength);
wpbEccentricity = vertcat(wpbFeatures.Eccentricity);
wpbEquivDiameter = vertcat(wpbFeatures.EquivDiameter);
wpbFeatures = horzcat(wpbArea, wpbCentroidX, wpbCentroidY, wpbMajorAxisLength, wpbMinorAxisLength, wpbEccentricity, wpbEquivDiameter);
xlswrite('C:\Users\Neslihan Gökmen\Desktop\Master&Doktora\Doktora18\Ýmage Proc\a.xls',wpbFeatures,'Sheet1','A158');
 
  


end


