% Get the selection without the white background (only chars will be left)
selection = rgb2gray(selection_rgb);
selection_bw = im2bw(selection, .42); %% TODO: CHECK THIS PARAMETER
selection_removebg = ~selection_bw .* selection_mask;
imsave(selection_removebg, 'test.selection.bw');

connComp = bwconncomp(selection_removebg);
regionFilteredTextMask = selection_removebg;
stats = regionprops(connComp,'Area','Eccentricity','Solidity','BoundingBox');

%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] > 300})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Eccentricity] > .995})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 2000})) = 0;
%regionFilteredTextMask(vertcat(connComp.PixelIdxList{[stats.Solidity] < .4})) = 0;

selection_removebg = regionFilteredTextMask;
imshow(selection_removebg);
%selection_removebg = imdilate(selection_removebg, strel('line', 2, 90));

% Fill holes for BoundingBox processing
Ifill = imfill(selection_removebg, 'holes');

[Ilabel num] = bwlabel(Ifill);
s = regionprops(Ilabel, 'BoundingBox');
Ibox = [s.BoundingBox];
Ibox = reshape(Ibox, [4 num]);

% Ibox = Ibox(:, (Ibox(3,:) .* Ibox(4,:)) < max(Ibox(3,:).*Ibox(4,:))*.2 );
Ibox(3,:) = Ibox(3,:) + 2;
Ibox(2,:) = Ibox(2,:) - 5;
Ibox(4,:) = Ibox(4,:) + 10;
% Ibox = Ibox(:, Ibox(4,:) > 5 );
% Plot the BoundingBoxes
figure; imshow(im);
hold on;
for cnt = 1:num
  rectangle('position', Ibox(:,cnt), 'edgecolor', 'r');
end

% f = getframe(gca);
% final = frame2im(f);
% imwrite(final, 'outputs/imgs/test.final.png');

hold off;