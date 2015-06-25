% Get the interestarea without the white background (only chars will be left)
processed = rgb2gray(interestarea_rgb);
processed_bw = im2bw(processed, .42);
processed_removebg = ~processed_bw .* interestarea_mask;

% If we need some filters, here are some
%%Get properties of connected components
%connComp = bwconncomp(processed_removebg);
%regionFilteredTextMask = processed_removebg;
%stats = regionprops(connComp,'Area','Eccentricity','Solidity','BoundingBox');
%
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] > 300})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;
%
%processed_removebg = regionFilteredTextMask;

% Fill holes for BoundingBox processing
Ifill = imfill(processed_removebg, 'holes'); % Fill any letter gap, as we have on "e" or "b"
Ifill = imerode( Ifill, strel('square', 2) ); % Removes "salt" objects (if need to)
Ifill = imdilate( Ifill, strel('line', 7, 90) ); % Do the magic for letters as i,j...

% Get the region props
[Ilabel num] = bwlabel(Ifill);
s = regionprops(Ilabel, 'BoundingBox', 'Extrema', 'Centroid', 'FilledArea', 'Area', 'Perimeter');

% Sort the boundings boxes
extrema = cat(1, s.Extrema);
left_most_bottom = extrema(6:8:end, :);
left = left_most_bottom(:, 1);
bottom = left_most_bottom(:, 2);
bottom = 6 * round(bottom / 6);
[sorted, sort_order] = sortrows([bottom left]);
s2 = s(sort_order);
boudingboxes_sorted = [s2.BoundingBox];
boudingboxes_sorted = reshape(boudingboxes_sorted, [4 num]);

% Preallocate the parameters for neural network params
params = zeros( 6, numel(s2) );
neural_target_params = zeros( 65, numel(s2) );
neural_target_params_final = neural_target_params;

% Plot the data and save neural net params
hold on;
imshow(im);
for k = 1:numel(s2)
   obj = s2(k);
   % text(obj.Centroid(1), obj.Centroid(2), sprintf('%d', k)); % shows the centroid order
   rectangle('position', boudingboxes_sorted(:,k), 'edgecolor', 'r'); % plot the bounding box
   
   % Crop the bounding box (just in case that you need to save or whatever)
   %crop = imcrop(im, boudingboxes_sorted(:,k));
   
   % OPTIMIZE BELOW
   params(1,k) = boudingboxes_sorted(3, k);                   % width
   params(2,k) = boudingboxes_sorted(4, k);                   % height
   params(3,k) = obj.FilledArea;                              % filled area
   params(4,k) = obj.Centroid(1) - boudingboxes_sorted(3, k); % centroid x
   params(5,k) = obj.Centroid(2) - boudingboxes_sorted(4, k); % centroid y
   params(6,k) = obj.Perimeter;                               % perimeter
end
hold off;