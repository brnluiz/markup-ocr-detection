% % Extract each RGB channel to variables
r = paper_rgb(:,:,1);
g = paper_rgb(:,:,2);
b = paper_rgb(:,:,3);

% Get the difference of each channel. Only coloured parts will be at the final result
diff_r2g = imabsdiff(r,g);
diff_g2b = imabsdiff(g,b);
diff_abs = imabsdiff(diff_r2g, diff_g2b);

diff_abs = rgb2gray(paper_rgb);

% Filter the "marker selection" (colored part) to be more consistent
se_selection_erode = strel ('disk', 1, 0); % this will give more "error margin" when you try to extract the chars
se_selection = strel ('disk', 4, 0); % this will give more "error margin" when you try to extract the chars
blur_filter = fspecial('gaussian',[5 5],2);
paper_selection = diff_abs > 20; %% TODO: CHECK THIS PARAMETER
paper_selection = imerode(paper_selection, se_selection_erode);
paper_selection = imdilate(paper_selection, se_selection);
% paper_selection = imfilter(paper_selection, blur_filter, 'same');
% paper_selection = imsmooth(paper_selection, 'gaussian');

% selection_mask = paper_selection; 
selection_mask = paper_selection;

selection_mask2(:,:,1) = paper_selection;
selection_mask2(:,:,2) = paper_selection;
selection_mask2(:,:,3) = paper_selection;
selection_mask2        = uint8(selection_mask2);

selection_rgb = uint8(im) .* uint8(selection_mask2);
imsave(selection_mask, 'test.selection.mask');
imsave(paper_selection, 'test.selection');