im_gray = rgb2gray(im);

% Removes unwanted objects by threshold
threshold = max(mean(im_gray)) / 255;
im_bw = im2bw(im_gray, threshold);

% Parameters for processing
se_dilate = strel('disk', 1, 0);
se_erode = strel('disk', 10, 0);

% Filter the image to leave only the "paper" object
im_dilate = imdilate(im_bw, se_dilate); % Dilate spaces in paper
im_fill = imfill(im_dilate, 'holes');   % Fill the gaps
im_erode = imerode(im_fill, se_erode);  % Remove unwated objects
im_center = imclearborder(im_erode);    % Remove border elements

% Masks the RGB image and leave only the paper area on the RGB var
paper_mask            = im_erode;
paper_mask_rgb(:,:,1) = paper_mask;
paper_mask_rgb(:,:,2) = paper_mask;
paper_mask_rgb(:,:,3) = paper_mask;
paper_mask_rgb        = uint8(paper_mask_rgb);

paper_rgb = im .* paper_mask_rgb;