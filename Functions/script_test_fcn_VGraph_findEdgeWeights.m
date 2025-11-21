% script_test_fcn_VGraph_findEdgeWeights
% Tests: fcn_VGraph_findEdgeWeights

% REVISION HISTORY:
% 
% As: fcn_general_calculation_euclidean_point_to_point_distance
% 
% 2022_11_01 by S. Harnett
% - first write of script
%
% As: fcn_BoundedAStar_findEdgeWeights
% 
% 2025_07_08 - K. Hayes, kxh1031@psu.edu
% - Replaced fcn_general_calculation_euclidean_point_to_point_distance
%   % with vector sum method 
% 
% 2025_08_07 - K. Hayes 
% - moved test to new script 
% - fixed script formatting
% - moved plotting to function debug 
% 
% 2025_10_03 - K. Hayes
% - fixed bug causing assertion failure in DEMO case 1
% 
% 2025_11_02 by Sean Brennan, sbrennan@psu.edu
% - changed fcn_BoundedAStar_polytopesGenerateAllPtsTable 
%   % to fcn_Visibility_polytopesGenerateAllPtsTable
%   % WARNING: inputs/outputs to this changed slightly. Function needs to 
%   % be rechecked
%
% As: fcn_VGraph_findEdgeWeights
% 
% 2025_11_06 by Sean Brennan, sbrennan@psu.edu
% - Renamed function
%   % * from fcn_BoundedAStar_findEdgeWeights
%   % * to fcn_VGraph_findEdgeWeights
% - Cleaned up variable naming:
%   % * From fig+_num to figNum
%   % * From all+_pts to pointsWithData
%   % * From ga+_size to gapSize
%   % * From cg+raph to cost+Graph
%
% 2025_11_17 by Sean Brennan, sbrennan@psu.edu
% - Updated formatting to Markdown on Rev history
% - Cleaned up variable naming in all functions
%   % cos+tGraph to cGraph
%   % vgra+ph to vGraph

% TO-DO:
% - Need to finish function
% - Need to add fastmode testing once function is working


%%%%%%%%%%%%%%§

%% Set up the workspace
close all

%% Code demos start here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____                              ____   __    _____          _
%  |  __ \                            / __ \ / _|  / ____|        | |
%  | |  | | ___ _ __ ___   ___  ___  | |  | | |_  | |     ___   __| | ___
%  | |  | |/ _ \ '_ ` _ \ / _ \/ __| | |  | |  _| | |    / _ \ / _` |/ _ \
%  | |__| |  __/ | | | | | (_) \__ \ | |__| | |   | |___| (_) | (_| |  __/
%  |_____/ \___|_| |_| |_|\___/|___/  \____/|_|    \_____\___/ \__,_|\___|
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Demos%20Of%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: DEMO cases\n');

%% DEMO case: find edge weights
figNum = 10001;
titleString = sprintf('DEMO case: find edge weights');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

fileName = 'DATA_testing_fcn_VGraph_findEdgeWeights.mat';
fullPath = fullfile(pwd,'Data',fileName);
if (1==0) && exist(fullPath, 'file')
    load(fullPath,'polytopes','pointsWithData','gapSize');
else

    %%%%%%%%%%
    mapStretch = [1 1];
    set_range = [11 15];

    rng(1234);

    Nsets = 1;
    seedGeneratorNames  = cell(Nsets,1);
    seedGeneratorRanges = cell(Nsets,1);
    AABBs               = cell(Nsets,1);
    mapStretchs        = cell(Nsets,1);

    ith_set = 0;

    ith_set = ith_set+1;
    seedGeneratorNames{ith_set,1} = 'haltonset';
    seedGeneratorRanges{ith_set,1} = set_range;
    AABBs{ith_set,1} = [0 0 1 1];
    mapStretchs{ith_set,1} = mapStretch;

    [tiled_polytopes] = fcn_MapGen_generatePolysFromSeedGeneratorNames(...
        seedGeneratorNames,...  % string or cellArrayOf_strings with the name of the seed generator to use
        seedGeneratorRanges,... % vector or cellArrayOf_vectors with the range of points from generator to use
        (AABBs),...             % vector or cellArrayOf_vectors with the axis-aligned bounding box for each generator to use
        (mapStretchs),...       % vector or cellArrayOf_vectors to specify how to stretch X and Y axis for each set
        (figNum));

    % shink the polytopes so that they are no longer tiled
    gapSize = 0.05; % desired cut distance
    polytopes = fcn_MapGen_polytopesShrinkEvenly(tiled_polytopes,gapSize, figNum);

    % Generate all points table
    start_xy = [0 0];
    finish_xy = [0 0];
    if 1==1
        pointsWithDataRaw = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes,start_xy,finish_xy,-1);
        % Remove start and end
        pointsWithData = pointsWithDataRaw(1:end-2,:);
    else
        % % OLD:
        % pointsWithData = fcn_BoundedAStar_polytopesGenerateAllPtsTable(polytopes,start_xy,finish_xy,-1);
    end
    
    %%%%%

    save(fullPath,'polytopes','pointsWithData','gapSize');

end

% Calculate weighted visibility graph (cost graph)
[cGraph, vGraph] = fcn_VGraph_findEdgeWeights(polytopes, pointsWithData, gapSize, figNum);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(cGraph));
assert(isnumeric(vGraph));

% Check variable sizes
Npoly = 5;
assert(isequal(Npoly,length(polytopes))); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


%% Test cases start here. These are very simple, usually trivial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  _______ ______  _____ _______ _____
% |__   __|  ____|/ ____|__   __/ ____|
%    | |  | |__  | (___    | | | (___
%    | |  |  __|  \___ \   | |  \___ \
%    | |  | |____ ____) |  | |  ____) |
%    |_|  |______|_____/   |_| |_____/
%
%
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 2

close all;
fprintf(1,'Figure: 2XXXXXX: TEST mode cases\n');

%% TEST case: zero gap between polytopes
figNum = 20001;
titleString = sprintf('TEST case: zero gap between polytopes');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;


%% Fast Mode Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ______        _     __  __           _        _______        _
% |  ____|      | |   |  \/  |         | |      |__   __|      | |
% | |__ __ _ ___| |_  | \  / | ___   __| | ___     | | ___  ___| |_ ___
% |  __/ _` / __| __| | |\/| |/ _ \ / _` |/ _ \    | |/ _ \/ __| __/ __|
% | | | (_| \__ \ |_  | |  | | (_) | (_| |  __/    | |  __/\__ \ |_\__ \
% |_|  \__,_|___/\__| |_|  |_|\___/ \__,_|\___|    |_|\___||___/\__|___/
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Fast%20Mode%20Tests
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figures start with 8

close all;
fprintf(1,'Figure: 8XXXXXX: FAST mode cases\n');

%% Basic example - NO FIGURE
figNum = 80001;
fprintf(1,'Figure: %.0f: FAST mode, empty figNum\n',figNum);
figure(figNum); close(figNum);

%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

% map_name = "HST 1 100 SQT 0 1 0 1 SMV 0.01 0.001 1e-6 1111";
% plot_flag = 1; 
% disp_name = 0; 
% 
% line_style = 'r-';
% line_width = 2;
% 
% Niterations = 10;
% 
% % Do calculation without pre-calculation
% tic;
% for ith_test = 1:Niterations
%     % Call the function
%     [polytopes, h_fig] = fcn_MapGen_generatePolysFromName(map_name, plot_flag, disp_name, ([]), (line_style), (line_width));
% end
% slow_method = toc;
% 
% % Do calculation with pre-calculation, FAST_MODE on
% tic;
% for ith_test = 1:Niterations
%     % Call the function
%     [polytopes, h_fig] = fcn_MapGen_generatePolysFromName(map_name, plot_flag, disp_name, (-1), (line_style), (line_width));
% end
% fast_method = toc;
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));
% 
% % Plot results as bar chart
% figure(373737);
% clf;
% hold on;
% 
% X = categorical({'Normal mode','Fast mode'});
% X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
% Y = [slow_method fast_method ]*1000/Niterations;
% bar(X,Y)
% ylabel('Execution time (Milliseconds)')
% 
% 
% % Make sure plot did NOT open up
% figHandles = get(groot, 'Children');
% assert(~any(figHandles==figNum));

%% BUG cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ____  _    _  _____
% |  _ \| |  | |/ ____|
% | |_) | |  | | |  __    ___ __ _ ___  ___  ___
% |  _ <| |  | | | |_ |  / __/ _` / __|/ _ \/ __|
% | |_) | |__| | |__| | | (_| (_| \__ \  __/\__ \
% |____/ \____/ \_____|  \___\__,_|___/\___||___/
%
% See: http://patorjk.com/software/taag/#p=display&v=0&f=Big&t=BUG%20cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All bug case figures start with the number 9

% close all;

%% BUG

%% Fail conditions
if 1==0

end


%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§
