clear; clc; close all;

%User Inputs 

fprintf('Assignment 1: Connected Component Labeling \n');

imgName = input('Enter the image file name : ', 's'); 

try
    img = imread(imgName); 
    if size(img, 3) == 3, grayImg = rgb2gray(img); else, grayImg = img; end
    
    thresh = input('Enter the threshold value for binarization (0-255): ');
    binaryImg = grayImg > thresh; 
catch
    error('Could not find or read the image file. Please check the name and extension.');
end

[rows, cols] = size(binaryImg);

%Task 1: 4-Connectivity Labeling (Two-Pass Algorithm)

labels4 = zeros(rows, cols); nextL4 = 1; parent4 = 1:50000;
for r = 2:rows
    for c = 2:cols
        if binaryImg(r,c) == 1
            neighbors = [labels4(r, c-1), labels4(r-1, c)];
            L = neighbors(neighbors > 0);
            if isempty(L)
                labels4(r,c) = nextL4; nextL4 = nextL4 + 1;
            else
                minL = min(L); labels4(r,c) = minL;
                for val = L
                    r1 = minL; while parent4(r1) ~= r1, r1 = parent4(r1); end
                    r2 = val; while parent4(r2) ~= r2, r2 = parent4(r2); end
                    if r1 ~= r2, parent4(max(r1,r2)) = min(r1,r2); end
                end
            end
        end
    end
end
% Pass 2 for Task 1
for r = 1:rows
    for c = 1:cols
        if labels4(r,c) > 0
            curr = labels4(r,c);
            while parent4(curr) ~= curr, curr = parent4(curr); end
            labels4(r,c) = curr;
        end
    end
end

%Task 2: 8-Connectivity Labeling

labels8 = zeros(rows, cols); nextL8 = 1; parent8 = 1:50000;
for r = 2:rows
    for c = 2:cols-1
        if binaryImg(r,c) == 1
            neighbors = [labels8(r, c-1), labels8(r-1, c), labels8(r-1, c-1), labels8(r-1, c+1)];
            L = neighbors(neighbors > 0);
            if isempty(L)
                labels8(r,c) = nextL8; nextL8 = nextL8 + 1;
            else
                minL = min(L); labels8(r,c) = minL;
                for val = L
                    r1 = minL; while parent8(r1) ~= r1, r1 = parent8(r1); end
                    r2 = val; while parent8(r2) ~= r2, r2 = parent8(r2); end
                    if r1 ~= r2, parent8(max(r1,r2)) = min(r1,r2); end
                end
            end
        end
    end
end
% Pass 2 for Task 2
for r = 1:rows
    for c = 1:cols
        if labels8(r,c) > 0
            curr = labels8(r,c);
            while parent8(curr) ~= curr, curr = parent8(curr); end
            labels8(r,c) = curr;
        end
    end
end

% Task 3: Intensity Range Connectivity (V = {min-max})

fprintf('\n--- Task 3: Intensity Range ---\n');
minV = input('Enter Min intensity for V set (0-255): ');
maxV = input('Enter Max intensity for V set (0-255): ');

labelsRange = zeros(rows, cols); nextLV = 1; parentV = 1:50000;
for r = 2:rows
    for c = 2:cols-1
     
        if grayImg(r,c) >= minV && grayImg(r,c) <= maxV
            neighbors = [labelsRange(r, c-1), labelsRange(r-1, c), labelsRange(r-1, c-1), labelsRange(r-1, c+1)];
            L = neighbors(neighbors > 0);
            if isempty(L)
                labelsRange(r,c) = nextLV; nextLV = nextLV + 1;
            else
                minL = min(L); labelsRange(r,c) = minL;
                for val = L
                    r1 = minL; while parentV(r1) ~= r1, r1 = parentV(r1); end
                    r2 = val; while parentV(r2) ~= r2, r2 = parentV(r2); end
                    if r1 ~= r2, parentV(max(r1,r2)) = min(r1,r2); end
                end
            end
        end
    end
end
% Pass 2 for Task 3
for r = 1:rows
    for c = 1:cols
        if labelsRange(r,c) > 0
            curr = labelsRange(r,c);
            while parentV(curr) ~= curr, curr = parentV(curr); end
            labelsRange(r,c) = curr;
        end
    end
end

%Task 4: Size Filter

fprintf('\n--- Task 4: Size Filtering ---\n');
minSize = input('Enter minimum pixel count (Size Filter Threshold): ');
filteredLabels = labels8; 
uniqueL = unique(labels8(labels8 > 0));
for i = 1:length(uniqueL)
    currL = uniqueL(i);
    if sum(labels8(:) == currL) < minSize
        filteredLabels(labels8 == currL) = 0;
    end
end

% Final Result Display 
figure('Name', ['Results for ' imgName], 'NumberTitle', 'off');

subplot(2,2,1); imshow(label2rgb(labels4, 'jet', 'k', 'shuffle'));
title(['Task 1: 4-Conn (T:' num2str(thresh) ')']);

subplot(2,2,2); imshow(label2rgb(labels8, 'jet', 'k', 'shuffle'));
title(['Task 2: 8-Conn (T:' num2str(thresh) ')']);

subplot(2,2,3); imshow(label2rgb(labelsRange, 'jet', 'k', 'shuffle'));
title(['Task 3: V=[' num2str(minV) '-' num2str(maxV) ']']);

subplot(2,2,4); imshow(label2rgb(filteredLabels, 'jet', 'k', 'shuffle'));
title(['Task 4: Size Filter > ' num2str(minSize)]);

fprintf('\nProcess completed successfully.\n');