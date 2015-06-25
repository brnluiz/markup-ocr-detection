if markup_detection == true
    disp 1
    % % Extract each RGB channel to variables
    r = paper_rgb(:,:,1);
    g = paper_rgb(:,:,2);
    b = paper_rgb(:,:,3);

    % Get the difference of each channel. Only coloured parts will be at the final result
    diff_r2g = imabsdiff(r,g);
    diff_g2b = imabsdiff(g,b);
    
    diff_abs = imabsdiff(diff_r2g, diff_g2b);
else
    diff_abs = rgb2gray(paper_rgb);
end

% Parameters for processing
se_interestarea_erode = strel ('disk', 1, 0); % this will give more "error margin" when you try to extract the chars
se_interestarea = strel ('disk', 4, 0); % this will give more "error margin" when you try to extract the chars

% Filter the "markup" (colored part) to be more consistent
paper_threshold = diff_abs > 20;
paper_erode = imerode(paper_threshold, se_interestarea_erode);
paper_dilate = imdilate(paper_erode, se_interestarea);

% Masks the RGB paper and leave the paper or markup (depending on the config)
interestarea_mask            = paper_dilate;
interestarea_mask_rgb(:,:,1) = interestarea_mask;
interestarea_mask_rgb(:,:,2) = interestarea_mask;
interestarea_mask_rgb(:,:,3) = interestarea_mask;
interestarea_mask_rgb        = uint8(interestarea_mask_rgb);

interestarea_rgb = im .* interestarea_mask_rgb;