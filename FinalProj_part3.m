clear;
clc;
close all;

%%% Declaring parameters for the retargeting
minImgSize = 30;                % lowest scale resolution size for min(w, h)
outSizeFactor = [1, 0.65];		% the ration of output image
numStages = 10;                 % number of scales (distributed logarithmically)
niters = 5;
patch_size = [7 7];

%% Preparing data for the retargeting
image = imread('../Images/SimakovFarmer.png');
%image = imread('../Images/test.jpg');
[h, w, ~] = size(image);

targetSize = ceil(outSizeFactor .* [h, w]);
S = double(image);
course_resize_ratio = ceil(h*minImgSize/(outSizeFactor(2)*w))/h;
Scoarse = double(imresize(S,course_resize_ratio));
Tcoarse_size = floor(targetSize*course_resize_ratio);
downscale_intervals = size(Scoarse,2)-1:-1:Tcoarse_size(2);


%% STEP 1 - do the retargeting at the coarsest level
disp('STEP 1 STARTED');
T = Scoarse;

index = 1;
total_time_part1 = 0;

for cols = downscale_intervals
    tic
    T_init = double(imresize(T,[Tcoarse_size(1) cols])); %Resize to one column smaller
    T = my_search_vote_func2(Scoarse,T_init, niters, patch_size(1), patch_size(2), [], []);
        
    time_end = toc;
    fprintf('Step1 progress: %d/%d\t Time = %d seconds\n',index,length(downscale_intervals),round(time_end));
    figure(1);
    subplot(4,5,index), imshow(T/255)
    str = [num2str(size(T,1)) 'x' num2str(size(T,2))];
    title(str);
    index = index + 1;
    total_time_part1 = total_time_part1 + time_end;
end
fprintf('Step 1 finished with total time %d seconds\n',round(total_time_part1));

%% STEP 2 - do resolution refinement 
disp('STEP 2 STARTED');

% Get scaling intervals
for i = 1:numStages
   targetRowIntervals(i) = ceil((targetSize(1)-size(T,1))/numStages*(i) + size(T,1));
   targetColIntervals(i) = ceil((targetSize(2)-size(T,2))/numStages*(i) + size(T,2));
   sourceRowIntervals(i) = ceil((size(S,1)-size(Scoarse,1))/numStages*(i) + size(Scoarse,1));
   sourceColIntervals(i) = ceil((size(S,2)-size(Scoarse,2))/numStages*(i) + size(Scoarse,2));
end

total_time_part2 = 0;
for i = 1:numStages
    tic
    SDownScaled = double(imresize(S,[sourceRowIntervals(i) sourceColIntervals(i)]));
    T_init2 = double(imresize(T,[targetRowIntervals(i) targetColIntervals(i)]));
    T = my_search_vote_func2(SDownScaled,T_init2, niters, patch_size(1), patch_size(2), [], []);
    
    time_end = toc;
    fprintf('Step2 progress: %d/%d\t Time = %d seconds\n',i,numStages,round(time_end));
    figure(2);
    subplot(3,4,i), imshow(T/255)
    str = [num2str(size(T,1)) 'x' num2str(size(T,2))];
    title(str);
    total_time_part2 = total_time_part2 + time_end;
end

%% STEP 3 - do final scale iterations
disp('STEP 3 STARTED');
tic;
T_final = uint8(my_search_vote_func2(S,T, niters, patch_size(1), patch_size(2), [], []));

total_time_part3 = toc;
total_time = total_time_part1 + total_time_part2 + total_time_part3;

%% Show resulting image
figure;
imshow(T_final);
fprintf('FINISHED!\nTotal execution time was %d seconds\n',round(total_time));
