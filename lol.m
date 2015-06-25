bootstrap

% Load the RGB image and convert it to gray-scale
im = imread('imgs/test5.jpg');
global_vars

im_gray = rgb2gray(im);

% Removes unwanted objects by threshold
threshold = max(mean(im_gray)) / 255;
% threshold(threshold > .5) = .5;
im_bw = im2bw(im_gray, .8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

selection_removebg = im_bw; %% TODO: CHECK THIS PARAMETER

connComp = bwconncomp( selection_removebg );
% regionFilteredTextMask = selection_removebg;
stats = regionprops(connComp,'Area','Eccentricity','Solidity','BoundingBox');

%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] > 300})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;

% selection_removebg = regionFilteredTextMask;
imshow(selection_removebg);
%selection_removebg = imdilate(selection_removebg, strel('line', 2, 90));

% Fill holes for BoundingBox processing
% Ifill = imfill(selection_removebg, 'holes');
Ifill = imdilate( selection_removebg, strel('line', (0.0009971509972) * ySize, 90) );

[Ilabel num] = bwlabel(Ifill);
s = regionprops(Ilabel, 'BoundingBox', 'Extrema', 'Centroid', 'FilledArea', 'Perimeter');
Ibox = [s.BoundingBox];
Ibox = reshape(Ibox, [4 num]);

% % Ibox = Ibox(:, (Ibox(3,:) .* Ibox(4,:)) < max(Ibox(3,:).*Ibox(4,:))*.2 );
% Ibox(3,:) = Ibox(3,:) + 2; % DESCOMENTAR ESSA PORRA
% %Ibox(2,:) = Ibox(2,:) - 5;
% %Ibox(4,:) = Ibox(4,:) + 10;
% % Ibox = Ibox(:, Ibox(4,:) > 5 );
% % Plot the BoundingBoxes
% Itest = transpose(Ibox);
% Itest2 = sortrows(Itest, [1]);
% Ibox = transpose(Itest2);

extrema = cat(1, s.Extrema);
left_most_bottom = extrema(6:8:end, :);
left = left_most_bottom(:, 1);
bottom = left_most_bottom(:, 2);
% quantize the bottom coordinate
bottom = 6 * round(bottom / 6);
[sorted, sort_order] = sortrows([bottom left]);
s2 = s(sort_order);
imshow(im, 'InitialMag', 'fit')
hold on;

IboxSorted = [s2.BoundingBox];
IboxSorted = reshape(IboxSorted, [4 num]);

for k = 1:numel(s2)
   centroid = s2(k).Centroid;
   text(centroid(1), centroid(2), sprintf('%d', k));
   rectangle('position', IboxSorted(:,k), 'edgecolor', 'r');
   
   paramsWidth      = IboxSorted(3, k);
   paramsHeight     = IboxSorted(4, k);
   paramsFilledArea = s2(k).FilledArea;
   paramsCx         = s2(k).Centroid(1);
   paramsCy         = s2(k).Centroid(2);
   paramsPerimeter  = s2(k).Perimeter;
end

subImage = imcrop(im, Ibox(:,1));

% f = getframe(gca);
% final = frame2im(f);
% imwrite(final, 'outputs/imgs/test.final.png');

hold off;