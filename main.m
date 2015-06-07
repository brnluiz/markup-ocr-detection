% Load the most recent image package
pkg load image

% Load the RGB image and convert it to gray-scale
im = imread('imgs/test1.jpg');
im_gray = rgb2gray(im);
% im_gray = imresize(im_gray, .5);

% START OF PAPER PART
% Removes unwanted objects by threshold
threshold = graythresh(im_gray);
im_bw = im2bw(im_gray, .5);

% Removes unwanted objects
se_paper = strel('diamond', 10);
im_open = imopen(im_bw, se_paper);
im_close = imclose(im_open, se_paper);

% Fill the remanescent gaps
im_fill = bwfill(im_close, 'holes');

% Get the largest element (by largest area)
% In this project, it will be the paper
im_bwpropfilt = bwpropfilt(im_fill,'Area',1);


% Masks the RGB image and leave only the paper area
paper_mask = im_bwpropfilt;
paper_rgb  = im .* paper_mask;
imwrite(paper_rgb, 'output/imgs/test.paper.png');
% END OF PAPER PART

% START OF SELECTION PART
% Extract each RGB channel to variables
r = paper_rgb(:,:,1);
g = paper_rgb(:,:,2);
b = paper_rgb(:,:,3);

% Get the difference of each channel. Only coloured parts will be at the final result
diff_r2g = imabsdiff(r,g);
diff_g2b = imabsdiff(g,b);
diff_abs = imabsdiff(diff_r2g, diff_g2b);

% Filter the "marker selection" (colored part) to be more consistent
se_selection = strel('disk', 6, 0); % this will give more "error margin" when you try to extract the chars
paper_selection1 = diff_abs > 50;
paper_selection2 = imdilate(paper_selection1, se_selection);
% paper_selection3 = imsmooth(paper_selection2, 'gaussian');

selection_mask = paper_selection2; 
selection_rgb  = im .* selection_mask;
imwrite(selection_rgb, 'output/imgs/test.selection.png');
% END OF SELECTION PART

% START OF BOUNDING BOXES PART
% Get the selection without the white background (only chars will be left)
selection = rgb2gray(selection_rgb);
selection_bw = im2bw(selection, .42);
selection_removebg = !selection_bw .* selection_mask;
imwrite(selection_removebg, 'output/imgs/test.selection.bw.png');

% Fill holes for BoundingBox processing
Ifill = bwfill(selection_removebg, 'holes');

[Ilabel num] = bwlabel(Ifill);
s = regionprops(Ilabel, 'BoundingBox');
Ibox = [s.BoundingBox];
Ibox = reshape(Ibox, [4 num]);

% Plot the BoundingBoxes
figure; imshow(im);
hold on;
for cnt = 1:num
  rectangle('position', Ibox(:,cnt), 'edgecolor', 'r');
end

f = getframe(gca);
final = frame2im(f);
imwrite(final, 'output/imgs/test.final.png');

hold off;