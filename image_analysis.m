%Matlab Script for analysis of digital images of viruses

%Basic Pipeline
%1) Pulls in FITC (DNA signal from Sybr gold) and Cy3 (Tamara Azide click signal) grayscale images
%2) Corrects the images for background
%3) Uses the FITC image to create ROIs based on fluorescent threshold and
%creates a mask
%4) Applies this same mask to the Cy3 image
%5) Applies a size cutoff 
%6) Normalizes by exposure time
%7) Saves fluorescent intensity data
%8) Determines R to G ratios for ROIs that are correct size and saves this
%data

%%
%Read in Images

%Image 1
%read in GREEN image
FITC = imread('EhV_FITC_negHPG.tif');
%read in RED image (Tamara clicked image)
Cy3 = imread('EhV_Cy3_negHPG.tif');

filename = 'EhV_negHPG';

%exposure time (units ms) %determined my the user when images were captured.
ExpFITC = 150;
ExpCy3 = 500;
%%
%Background subtraction based on disk structuring element

background = imopen(FITC,strel('disk',40)); 
FITCbs = FITC-background;
    %figure; imshow(mat2gray(FITCbs))

background = imopen(Cy3,strel('disk',40));
Cy3bs = Cy3-background;
    %figure; imshow(mat2gray(Cy3bs))

%%
%Alignment of FITC and Cy3 images

%Thresholding - need good binary image for alignment to work,
%so values for thresholding may be tweaked a bit, particulary for Cy3 negative
%images
FITCth = double(im2bw(mat2gray(FITCbs),0.1));  % thresholding background subtracted images for alignment
Cy3th = double(im2bw(mat2gray(Cy3bs),0.2));  % thresholding background subtracted images for alignment
figure; imshow(FITCth)
figure; imshow(Cy3th)

FITCsized = FITCth - bwareaopen(FITCth,30);  % remove big spots (>30 pixels)
Cy3sized = Cy3th - bwareaopen(Cy3th,30);  % remove big spots (>30 pixels)
Cy3sized_pad = padarray(Cy3sized,[20 20],'both'); % adds padding of zeros around Cy3 image so you can move it around over FITC image.

record = 10^9;  % sets the variable "record" to a big number
% Loop over x and y from 1 to 40, which will just move the Cy3 thresholded
% image over the FITC thresholded image from -20 to +20 in x and y. 
% For each loop it will subtract one image from the other, when things are
% poorly aligned this will end up with a result that has a lot of -1 and +1
% values.  Sum of the absolute value of that will be a big number.
% For a good alignment most of the image will be 0-0 or 1-1 so everything will be
% zero. 
% Stores the values for x,y shift that makes the smalest value.
for i=1:40
    for j=1:40
        score=sum(sum(abs(FITCsized-Cy3sized_pad(i:i+1039,j:j+1391))));
        if score<record
            record=score
            coords=[i,j]
        end
    end
end
FITCth = im2bw(mat2gray(FITCbs),0.1);

%Coords variable - tells you how much the images are offset.
    %Note - value for coords should be [20, 20] plus or minus a few (20, 20 would be no offset, so 23, 21 means a 3 pixel offset in one direction and a 1 pixel offset in the other).  
    %If coords gives you something like [1,20] then it broke because the thresholding is off and it just tried to move one image as far from the other as possible.

%The "padarray" part puts padding of zeros around the Cy3 image so that a subset of it with some offset that is the size of the FITC image can be subtracted from the FITC image.  

%For loop moves the Cy3 image over the FITC image one pixel at a time, subtracts one from the other and sees if its a better or worse alignment then the previous loop based on the difference between the two images.
%%
% RUN for alignment demonstration only
% pre_align = cat(3,Cy3sized,FITCsized,zeros(size(FITCth)));
% post_align = cat(3,Cy3sized_pad(coords(1):coords(1)+1039,coords(2):coords(2)+1391),FITCsized,zeros(size(FITCth)));
% subplot(1,2,1)
% imshow(pre_align(200:300,200:500,:))
% subplot(1,2,2)
% imshow(post_align(200:300,200:500,:))
%%
%Align Cy3 image using the offet determined above. It makes a background subtracted and normal version.
Cy3_pad = uint16(padarray(Cy3,[20 20],'both'));
Cy3bs_pad = uint16(padarray(Cy3bs,[20 20],'both'));
Cy3_aligned = Cy3_pad(coords(1):coords(1)+1039,coords(2):coords(2)+1391);
Cy3bs_aligned = Cy3bs_pad(coords(1):coords(1)+1039,coords(2):coords(2)+1391);

%%
%Apply size cutoff to data based on Major axis length of SYBR stained particle
MASK_STATS = regionprops(FITCth, 'centroid', 'area', 'majoraxislength');
FITClabel = bwlabel(FITCth); %make an image with Original unit16 images (not the mat3gray image)
MajorAxisLength = [MASK_STATS.MajorAxisLength]';
uM = MajorAxisLength./9.9608; %pixels per um conversion (depends on scope used)
Size_cutoff= find(uM < 0.45); %Choose particles less than 450 nm (0.450 um)

%%
%Pulling out stats from images

%Stats of images that have been aligned and background corrected
FITCbs_STATS = regionprops(FITCth,FITCbs, 'centroid', 'area', 'majoraxislength','maxintensity');
Cy3bs_STATS = regionprops(FITCth,Cy3bs_aligned, 'centroid', 'area', 'majoraxislength','maxintensity');

%Find max intensities of each ROI for images background corrected
Cy3bs_max = double([Cy3bs_STATS.MaxIntensity]');
FITCbs_max = double([FITCbs_STATS.MaxIntensity]');

Cy3bs_max_sizecut=Cy3bs_max(Size_cutoff);
FITCbs_max_sizecut=FITCbs_max(Size_cutoff);

%%
%Save Data that is background corrected
%converting structure to dataset and exporting as a text file
ds0 = struct2dataset(FITCbs_STATS);
export(ds0,'File',[filename '_GREEN_STATS'])

ds1 = struct2dataset(Cy3bs_STATS);
export(ds1,'File',[filename '_RED_STATS'])

%%
%Ploting centroids on images
%plot centroids on image that will be considered based on size
centroids= cat(1, MASK_STATS.Centroid);
centroids_size_1 = centroids(Size_cutoff,1);
centroids_size_2 = centroids(Size_cutoff,2);
centroids_size = cat(2,centroids_size_1, centroids_size_2);
figure, imshow(FITCth)
hold on
plot(centroids_size(:,1),centroids_size(:,2),'ro')
hold off

%%
%Calculating Red to Green Ratios and plotting

%Red to green ratios
R2G_ratiobs = (Cy3bs_max(Size_cutoff)./ExpCy3)./(FITCbs_max(Size_cutoff)./ExpFITC); %background subtracted

%Plotting distribution of RtoG ratios
figure; 
hist(R2G_ratiobs,50)
title('Red to Green Ratio Corrected','Interpreter','Latex')

%Saving R to G data for export and examination
save([filename '_RtoG_Corrected_Data'],'R2G_ratiobs','-ASCII')
save([filename '_RtoG_Corrected_Data'],'R2G_ratiobs')
%%
