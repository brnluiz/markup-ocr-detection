im_gray = rgb2gray(im);

% Removes unwanted objects by threshold
threshold = max(mean(im_gray)) / 255;
% threshold(threshold > .5) = .5;
im_bw = im2bw(im_gray, threshold);

% Removes unwanted objects
% se_paper = strel('diamond', 10);
se_dilate = strel('disk', 1, 0);
im_dilate = imdilate(im_bw, se_dilate);

% im_erode = imerode(im_dilate, se_erode);
im_process_final = im_dilate;

% Fill the remanescent gaps
im_fill = imfill(im_process_final, 'holes');

se_erode = strel('disk', 10, 0);
im_fill2 = imerode(im_fill, se_erode);

% Get the largest element (by largest area)
% In this project, it will be the paper
% im_bwpropfilt = bwpropfilt(im_fill2,'Area',1);

% Remove border elements
im_center = imclearborder(im_fill2);


% Masks the RGB image and leave only the paper area
% paper_mask = im_bwpropfilt;
paper_mask(:,:,1) = im_center;
paper_mask(:,:,2) = im_center;
paper_mask(:,:,3) = im_center;
paper_mask        = uint8(paper_mask);

paper_rgb = im .* paper_mask;
imsave(paper_rgb, 'test.paper');