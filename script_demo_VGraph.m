%% Introduction to and Purpose of the Code
% This is the explanation of the code that can be found by running
%       script_demo_VGraph.m
% This is a script to demonstrate the functions within the VGraph code
% library. This code repo is typically located at:
%   https://github.com/ivsg-psu/PathPlanning_GridFreePathPlanners_VGraph
%
% If you have questions or comments, please contact Sean Brennan at
% sbrennan@psu.edu
%
% The purpose of the Visibility Graph, or VGraph, code repo is to calculate
% the "visibility" of one point to another given a map containing
% polytopes. A "to" point is visible "from" another point if the line
% connecting the points does not pass through a polytope. The visibility
% graph is a core input for grid-free path planning.

% Revision history:
% 2025_10_28 - Sean Brennan
% -- created a the repo by removing visibility functions out of the
%    % BoundedAStar repo
% 2025_11_07
% -- fix bug with hardcoded expected vGraphs in
%    script_test_fcn_VGraph_clearAndBlockedPointsGlobal
% -- added fast mode test cases for all scropts
% 2025_11_08 - S. Brennan
% -- updated variable naming:
%    % * fig_num to figNum
%    % * vgraph to vGraph
%    % * all_pts to pointsWithData
%    % * start to startPointData or startXY, depending on usage
%    % * finish to finishPointData or finishXY, depending on usage
% -- fixed minor MATLAB warnings

% TO-DO:
% 20XX_XX_XX - Your name, your email
% -- list of items to add to the to-do list

clear library_name library_folders library_url

ith_library = 1;
library_name{ith_library}    = 'DebugTools_v2025_11_06';
library_folders{ith_library} = {'Functions','Data'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/archive/refs/tags/DebugTools_v2025_11_06.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'MapGenClass_v2025_11_09';
library_folders{ith_library} = {'Functions','testFixtures','GridMapGen'};
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary/archive/refs/tags/MapGenClass_v2025_11_09.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PathClass_v2025_08_03';
library_folders{ith_library} = {'Functions', 'Data'};                                
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary/archive/refs/tags/PathClass_v2025_08_03.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'PlotRoad_v2025_11_06';
library_folders{ith_library} = {'Functions', 'Data'};                                
library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad/archive/refs/tags/PlotRoad_v2025_11_06.zip';

ith_library = ith_library+1;
library_name{ith_library}    = 'GeometryClass_v2025_10_20';
library_folders{ith_library} = {'Functions', 'Data'};                                
library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_GeomClassLibrary/archive/refs/tags/GeometryClass_v2025_10_20.zip';

% ith_library = ith_library+1;
% library_name{ith_library}    = 'GPSClass_v2023_04_21';
% library_folders{ith_library} = {''};
% library_url{ith_library}     = 'https://github.com/ivsg-psu/FieldDataCollection_GPSRelatedCodes_GPSClass/archive/refs/tags/GPSClass_v2023_04_21.zip';
% 
% ith_library = ith_library+1;
% library_name{ith_library}    = 'GetUserInputPath_v2025_04_27';
% library_folders{ith_library} = {''};
% library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_PathTools_GetUserInputPath/blob/main/Releases/GetUserInputPath_v2025_04_27.zip?raw=true';
% 
% ith_library = ith_library+1;
% library_name{ith_library}    = 'AlignCoordinates_2023_03_29';
% library_folders{ith_library} = {'Functions'};
% library_url{ith_library}     = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_AlignCoordinates/blob/main/Releases/AlignCoordinates_2023_03_29.zip?raw=true';


%% Clear paths and folders, if needed
if 1==1
    clear flag_VGraph_Folders_Initialized
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;

end

%% Do we need to set up the work space?
if ~exist('flag_VGraph_Folders_Initialized','var')
    this_project_folders = {...
        'Functions','Data'};
    fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders);  
    flag_VGraph_Folders_Initialized = 1;
end

%% Set environment flags for input checking in HSOV library
% These are values to set if we want to check inputs or do debugging
setenv('MATLABFLAG_VGRAPH_FLAG_CHECK_INPUTS','1');
setenv('MATLABFLAG_VGRAPH_FLAG_DO_DEBUG','0');

%% Set environment flags for input checking in Geometry library
% setenv('MATLABFLAG_GEOMETRY_FLAG_CHECK_INPUTS','0');
% setenv('MATLABFLAG_GEOMETRY_FLAG_DO_DEBUG','0');

% %% Set environment flags that define the ENU origin
% % This sets the "center" of the ENU coordinate system for all plotting
% % functions
% 
% % Location for Test Track base station
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_LATITUDE','40.86368573');
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_LONGITUDE','-77.83592832');
% setenv('MATLABFLAG_PLOTROAD_REFERENCE_ALTITUDE','344.189');
% 
% 
% %% Set environment flags for plotting
% % These are values to set if we are forcing image alignment via Lat and Lon
% % shifting, when doing geoplot. This is added because the geoplot images
% % are very, very slightly off at the test track, which is confusing when
% % plotting data
% setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LAT','-0.0000008');
% setenv('MATLABFLAG_PLOTROAD_ALIGNMATLABLLAPLOTTINGIMAGES_LON','0.0000054');

%% Start of Demo Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   _____ _             _            __   _____                          _____          _
%  / ____| |           | |          / _| |  __ \                        / ____|        | |
% | (___ | |_ __ _ _ __| |_    ___ | |_  | |  | | ___ _ __ ___   ___   | |     ___   __| | ___
%  \___ \| __/ _` | '__| __|  / _ \|  _| | |  | |/ _ \ '_ ` _ \ / _ \  | |    / _ \ / _` |/ _ \
%  ____) | || (_| | |  | |_  | (_) | |   | |__| |  __/ | | | | | (_) | | |___| (_) | (_| |  __/
% |_____/ \__\__,_|_|   \__|  \___/|_|   |_____/ \___|_| |_| |_|\___/   \_____\___/ \__,_|\___|
%
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Start%20of%20Demo%20Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to the demo code for the Visibility Graph (VGraph) library!')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _____  _       _   _   _               ______                _   _
% |  __ \| |     | | | | (_)             |  ____|              | | (_)
% | |__) | | ___ | |_| |_ _ _ __   __ _  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
% |  ___/| |/ _ \| __| __| | '_ \ / _` | |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
% | |    | | (_) | |_| |_| | | | | (_| | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
% |_|    |_|\___/ \__|\__|_|_| |_|\__, | |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%                                  __/ |
%                                 |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Plotting+Functions&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% fcn_VGraph_plotVGraph - showing full graph
% Plots the visilibity graph for a field of polytopes

% This is DEMO case 10002 in the test script
figNum = 10001;
titleString = sprintf('fcn_VGraph_plotVGraph - showing full graph');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% load data
test_case_idx = 1;
[vGraph, pointsWithData, goodAxis, polytopes, startPointData, finishPointData, addNudge] = fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph(test_case_idx);


% Plot the polytopes
fcn_INTERNAL_plotPolytopes(polytopes, figNum)
axis(goodAxis);

% Plot the start and end points
plot(startPointData(1),startPointData(2),'.','Color',[0 0.5 0],'MarkerSize',20);
plot(finishPointData(1),finishPointData(2),'r.','MarkerSize',20);
text(startPointData(:,1),startPointData(:,2)+addNudge,'Start');
text(finishPointData(:,1),finishPointData(:,2)+addNudge,'Finish');

% label point ids for debugging. The last two points are start and
% finish, so do not need to be plotted and labeled.
plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));

% Call plotting function
selectedFromToIndices = [];
saveFile = [];
h_plot = fcn_VGraph_plotVGraph(vGraph, pointsWithData, 'g-', (selectedFromToIndices), (saveFile), (figNum));
axis(goodAxis);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(all(ishandle(h_plot)));

% Check variable sizes
assert(isequal(1,length(h_plot))); 

% Check variable values
assert(isequal(h_plot.Parent,gca)); % The parent of the plot is the axes
assert(isequal(h_plot.Parent.Parent,gcf)); % The parent of the axes is the current figure
assert(isequal(h_plot.Parent.Parent.Number,figNum)); % The current figure is this figure

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_plotVGraph - showing selected from index
% Plots the visilibity graph for a field of polytopes only showing
% user-selected "from" point

% This is DEMO case 10003 in the test script
figNum = 10002;
titleString = sprintf('fcn_VGraph_plotVGraph - showing selected from index');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% load data
test_case_idx = 1;
[vGraph, pointsWithData, goodAxis, polytopes, startPointData, finishPointData, addNudge] = fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph(test_case_idx);


% Plot the polytopes
fcn_INTERNAL_plotPolytopes(polytopes, figNum)
axis(goodAxis);

% Plot the start and end points
plot(startPointData(1),startPointData(2),'.','Color',[0 0.5 0],'MarkerSize',20);
plot(finishPointData(1),finishPointData(2),'r.','MarkerSize',20);
text(startPointData(:,1),startPointData(:,2)+addNudge,'Start');
text(finishPointData(:,1),finishPointData(:,2)+addNudge,'Finish');

% label point ids for debugging. The last two points are start and
% finish, so do not need to be plotted and labeled.
plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));

% Call plotting function
selectedFromToIndices = 1;
saveFile = [];
h_plot = fcn_VGraph_plotVGraph(vGraph, pointsWithData, 'g-', (selectedFromToIndices), (saveFile), (figNum));
axis(goodAxis);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(all(ishandle(h_plot)));

% Check variable sizes
assert(isequal(1,length(h_plot))); 

% Check variable values
assert(isequal(h_plot.Parent,gca)); % The parent of the plot is the axes
assert(isequal(h_plot.Parent.Parent,gcf)); % The parent of the axes is the current figure
assert(isequal(h_plot.Parent.Parent.Number,figNum)); % The current figure is this figure

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_plotVGraph - showing selected from/to index
% Plots the visilibity graph for a field of polytopes only showing
% user-selected "from" point and user-selected "to" point

% This is DEMO case 10004 in the test script
figNum = 10003;
titleString = sprintf('fcn_VGraph_plotVGraph - showing selected from/to index');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% load data
test_case_idx = 1;
[vGraph, pointsWithData, goodAxis, polytopes, startPointData, finishPointData, addNudge] = fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph(test_case_idx);


% Plot the polytopes
fcn_INTERNAL_plotPolytopes(polytopes, figNum)
axis(goodAxis);

% Plot the start and end points
plot(startPointData(1),startPointData(2),'.','Color',[0 0.5 0],'MarkerSize',20);
plot(finishPointData(1),finishPointData(2),'r.','MarkerSize',20);
text(startPointData(:,1),startPointData(:,2)+addNudge,'Start');
text(finishPointData(:,1),finishPointData(:,2)+addNudge,'Finish');

% label point ids for debugging. The last two points are start and
% finish, so do not need to be plotted and labeled.
plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));

% Call plotting function
selectedFromToIndices = [1 6];
saveFile = [];
h_plot = fcn_VGraph_plotVGraph(vGraph, pointsWithData, 'g-', (selectedFromToIndices), (saveFile), (figNum));
axis(goodAxis);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(all(ishandle(h_plot)));

% Check variable sizes
assert(isequal(1,length(h_plot))); 

% Check variable values
assert(isequal(h_plot.Parent,gca)); % The parent of the plot is the axes
assert(isequal(h_plot.Parent.Parent,gcf)); % The parent of the axes is the current figure
assert(isequal(h_plot.Parent.Parent.Number,figNum)); % The current figure is this figure

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_plotVGraph - showing animated gif
% Plots the visilibity graph for a field of polytopes only showing
% user-selected "from" point and user-selected "to" point

% This is DEMO case 10005 in the test script
figNum = 10004;
titleString = sprintf('fcn_VGraph_plotVGraph - animated');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% load data
test_case_idx = 1;
[vGraph, pointsWithData, goodAxis, polytopes, startPointData, finishPointData, addNudge] = fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph(test_case_idx);


% Plot the polytopes
fcn_INTERNAL_plotPolytopes(polytopes, figNum)
axis(goodAxis);

% Plot the start and end points
plot(startPointData(1),startPointData(2),'.','Color',[0 0.5 0],'MarkerSize',20);
plot(finishPointData(1),finishPointData(2),'r.','MarkerSize',20);
text(startPointData(:,1),startPointData(:,2)+addNudge,'Start');
text(finishPointData(:,1),finishPointData(:,2)+addNudge,'Finish');

% label point ids for debugging. The last two points are start and
% finish, so do not need to be plotted and labeled.
plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));

% Call plotting function
selectedFromToIndices = [];
saveFile = fullfile(pwd,'Images','fcn_VGraph_plotVGraph.gif');
h_plot = fcn_VGraph_plotVGraph(vGraph, pointsWithData, 'g-', (selectedFromToIndices), (saveFile), (figNum));
axis(goodAxis);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(all(ishandle(h_plot)));

% Check variable sizes
assert(isequal(length(pointsWithData(:,1)),length(h_plot))); 

% Check variable values
currentHandle = get(h_plot(1));
assert(isequal(currentHandle.Parent,gca)); % The parent of the plot is the axes
assert(isequal(currentHandle.Parent.Parent,gcf)); % The parent of the axes is the current figure
assert(isequal(currentHandle.Parent.Parent.Number,figNum)); % The current figure is this figure

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_polytopesGenerateAllPtsTable
% The following is test case 10001 in the test script
figNum = 10001;
titleString = sprintf('fcn_VGraph_polytopesGenerateAllPtsTable');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Create polytope field
raw_polytopes = fcn_MapGen_generatePolysFromSeedGeneratorNames('haltonset', [1 25],[], ([100 100]), (-1));

% Trim polytopes on edge of boundary
trim_polytopes = fcn_MapGen_polytopesDeleteByAABB( raw_polytopes, [0.1 0.1 99.9 99.9], (-1));

% Shrink polytopes to form obstacle field
polytopes = fcn_MapGen_polytopesShrinkEvenly(trim_polytopes, 2.5, (-1));

% Set x and y coordinates of each polytope
startXY = [0 0];
finishXY = [80 50];

% Generate pointsWithData table
[pointsWithData, startPointData, finishPointData] = ...
    fcn_VGraph_polytopesGenerateAllPtsTable(polytopes, ...
    (startXY), (finishXY), (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(pointsWithData));
assert(isnumeric(startPointData));
assert(isnumeric(finishPointData));

% Check variable sizes
Npoly = 10;
assert(isequal(Npoly,length(polytopes)));

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));
%% fcn_VGraph_calculatePointsOnLines
% This is demo case 10006 in the test script
figNum = 10006;
titleString = sprintf('DEMO case: fcn_VGraph_calculatePointsOnLines');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

x1 = [0 -0.5 0.25 -0.5];
y1 = [0 -0.75 -0.5 0];
x2 = [0.5 -0.5 0.75 -0.4];
y2 = [0.5 -0.25 -0.5 0.7];
acc = 0.2;

randomPoints = rand(10000,2);
xi = 2*randomPoints(:,1)' - 1;
yi = 2*randomPoints(:,2)' - 1;

flagIsOnLine = fcn_VGraph_calculatePointsOnLines(x1,y1,x2,y2,xi,yi,acc, (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(islogical(flagIsOnLine));

% Check variable sizes
Nsides = length(x1);
Npoints = length(xi);
assert(size(flagIsOnLine,1)==Npoints); 
assert(size(flagIsOnLine,2)==Nsides); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_findEdgeWeights
% Note: the following is test case 10001 in the test script

fig_num = 10001;
titleString = sprintf('DEMO case: find edge weights');
fprintf(1,'Figure %.0f: %s\n',fig_num, titleString);
figure(fig_num); clf;

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
[costGraph, vgraph] = fcn_VGraph_findEdgeWeights(polytopes, pointsWithData, gapSize, fig_num);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(costGraph));
assert(isnumeric(vgraph));

% Check variable sizes
Npoly = 5;
assert(isequal(Npoly,length(polytopes))); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),fig_num));

%% fcn_VGraph_selfBlockedPoints
% This is case 10001 in test script

figNum = 10001;
titleString = sprintf('fcn_VGraph_selfBlockedPoints');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Create polytope field
raw_polytopes = fcn_MapGen_generatePolysFromSeedGeneratorNames('haltonset', [1 25],[], ([100 100]), (-1));

% Trim polytopes on edge of boundary
trim_polytopes = fcn_MapGen_polytopesDeleteByAABB( raw_polytopes, [0.1 0.1 99.9 99.9], (-1));

% Shrink polytopes to form obstacle field
polytopes = fcn_MapGen_polytopesShrinkEvenly(trim_polytopes, 2.5, (-1));

% Create pointsWithData matrix
startXY = [-2.5, 1];
finishXY = startXY + [4 0];

if 1==1
    % Note: this includes start/finish points now
    pointsWithData = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes, startXY, finishXY,-1);
else
    % % OLD:
    % pointsWithData = fcn_BoundedAStar_polytopesGenerateAllPtsTable(shrunk_polytopes, start, finish,-1);
end

testPointData = pointsWithData(6,:);
[currentObstacleID, selfBlockedCost, pointsWithDataBlockedBySelf] = ...
    fcn_VGraph_selfBlockedPoints(polytopes,testPointData,pointsWithData,(figNum));

axis([40 70 60 85])
sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(currentObstacleID));
assert(isnumeric(selfBlockedCost));
assert(isnumeric(pointsWithDataBlockedBySelf));

% Check variable sizes
Npolys = 10;
assert(isequal(Npolys,length(polytopes))); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% Core functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                 ______                _   _
%  / ____|               |  ____|              | | (_)
% | |     ___  _ __ ___  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
% | |    / _ \| '__/ _ \ |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
% | |___| (_) | | |  __/ | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  \_____\___/|_|  \___| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Core+Functions&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% fcn_VGraph_clearAndBlockedPoints
% This is the first demo case in the script: find clear and blocked edges of polytopes in a map
figNum = 20001;
titleString = sprintf('DEMO case: fcn_VGraph_clearAndBlockedPoints');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Create polytope field
polytopes = fcn_MapGen_generatePolysFromSeedGeneratorNames('haltonset', [1 100],[], ([100 100]), (-1));

% Trim polytopes on edge of boundary
trim_polytopes = fcn_MapGen_polytopesDeleteByAABB( polytopes, [0.1 0.1 99.9 99.9], (-1));

% Shrink polytopes to form obstacle field
shrunk_polytopes = fcn_MapGen_polytopesShrinkEvenly(trim_polytopes, 2.5, (-1));

% Get x and y coordinates of each polytope
xvert = [shrunk_polytopes.xv];
yvert = [shrunk_polytopes.yv];
point_tot = length(xvert);

% Create start and finish points
startPointData = [0 50 point_tot+1 -1 0];
finishPointData = [[100; xvert'] [50; yvert'] [point_tot+2; (1:point_tot)'] [0; ones(point_tot,1)] [0; zeros(point_tot,1)]];

% Call function to determine clear and blocked points
isConcave = [];
[clear_pts,blocked_pts]=fcn_VGraph_clearAndBlockedPoints(shrunk_polytopes,startPointData,finishPointData,(isConcave),(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(clear_pts));
assert(isnumeric(blocked_pts));

% Check variable sizes
Npolys = 100;
assert(isequal(Npolys,length(polytopes))); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));





%% fcn_VGraph_clearAndBlockedPointsGlobal
% Note, this is test case 10002 in the test script

figNum = 20002;
titleString = sprintf('DEMO case: fcn_VGraph_clearAndBlockedPointsGlobal');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% convex polytope
convex_polytope(1).vertices = [0 0; 1 1; -1 2; -2 1; -1 0; 0 0];
convex_polytope(2).vertices = [1.5 1.5; 2 0.5; 3 3; 1.5 2; 1.5 1.5];
polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(convex_polytope);

% generate pointsWithData table
startXY = [-2.5, 1];
finishXY = [4 1];

pointsWithData = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes, startXY, finishXY,-1);

% Calculate visibility graph
isConcave = [];
[visibilityMatrix, visibilityDetailsEachFromPoint] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes,pointsWithData,pointsWithData,(isConcave),(figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(visibilityMatrix));
assert(isstruct(visibilityDetailsEachFromPoint));

% Check variable sizes
NpolyVertices = length([polytopes.xv]);
assert(size(visibilityMatrix,1)==NpolyVertices+2);
assert(size(visibilityMatrix,2)==NpolyVertices+2);
assert(size(visibilityDetailsEachFromPoint,2)==NpolyVertices+2);

% Check variable values
% Check this manually

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_addObstacle
% Note, this is test case 10001 in the test script

figNum = 20003;
titleString = sprintf('DEMO case: fcn_VGraph_addObstacle');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

dataFileName = 'DATA_fcn_VGraph_addObstacle_polytopeMapForTesting.mat';
fullDataFileWithPath = fullfile(pwd,'Data',dataFileName);
if exist(fullDataFileWithPath, 'file')
    load(fullDataFileWithPath,'polytopes');
else
    % Create polytope field
    raw_polytopes = fcn_MapGen_generatePolysFromSeedGeneratorNames('haltonset', [1 25],[], ([100 100]), (-1));

    % Trim polytopes on edge of boundary
    trim_polytopes = fcn_MapGen_polytopesDeleteByAABB( raw_polytopes, [0.1 0.1 99.9 99.9], (-1));

    % Shrink polytopes to form obstacle field
    polytopes = fcn_MapGen_polytopesShrinkEvenly(trim_polytopes, 2.5, (-1));

    % Set costs to uniform values
    for ith_poly = 1:length(polytopes)
        polytopes(ith_poly).cost = 0.4;
    end

    save(fullDataFileWithPath,'polytopes');

end

% Create pointsWithData matrix
startXY = [0, 50];
finishXY = [100, 50];

pointsWithData = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes, startXY, finishXY, -1);

startPointData = pointsWithData(end-1,:);
finishPointData = pointsWithData(end,:);

% Create visibility graph
isConcave = [];
visibilityMatrix =fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, pointsWithData, pointsWithData, (isConcave),(-1));

% add a polytope
polytopeToAdd = polytopes(1);
polytopeToAdd.xv = 0.5*polytopeToAdd.xv + 55;
polytopeToAdd.yv = 0.5*polytopeToAdd.yv - 10;
polytopeToAdd.vertices = [polytopeToAdd.xv' polytopeToAdd.yv'];

% Update visibilityMatrix with new polytope added
[newVisibilityMatrix, newPointsWithData, newStartPointData, newFinishPointData, newPolytopes] = ...
    fcn_VGraph_addObstacle(...
    visibilityMatrix, pointsWithData, startPointData, finishPointData, polytopes, polytopeToAdd, (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(newVisibilityMatrix));
assert(isnumeric(newPointsWithData));
assert(isnumeric(newStartPointData));
assert(isnumeric(newFinishPointData));
assert(isstruct(newPolytopes));

% Check variable sizes
NpointsOriginal= length(pointsWithData(:,1));
NpointsAdded = length(polytopeToAdd.vertices(:,1));
NpointsNew = NpointsOriginal + NpointsAdded;
assert(size(newVisibilityMatrix,1)==NpointsNew); 
assert(size(newVisibilityMatrix,2)==NpointsNew); 
assert(size(newPointsWithData,1)==NpointsNew); 
assert(size(newPointsWithData,2)==5); 
assert(size(newStartPointData,1)==1); 
assert(size(newStartPointData,2)==5); 
assert(size(newFinishPointData,1)==1); 
assert(size(newFinishPointData,2)==5); 
assert(size(newPolytopes,1)==1); 
assert(size(newPolytopes,2)==size(polytopes,2)+1); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% fcn_VGraph_generateDilationRobustnessMatrix
% Note: this is case 10003 in the test script

figNum = 10003;
titleString = sprintf('fcn_VGraph_generateDilationRobustnessMatrix');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load some test data 
dataSetNumber = 2; % Two polytopes with clear space right down middle
[all_pts, start, finish, vgraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix(dataSetNumber);

% Set options
mode = '2d';

plottingOptions.axis = goodAxis;
plottingOptions.selectedFromToToPlot = []; %[3 7];
plottingOptions.filename = []; % Specify the output file name

% Call the function
dilation_robustness_matrix = ...
    fcn_VGraph_generateDilationRobustnessMatrix(...
    all_pts, start, finish, vgraph, mode, polytopes,...
    (plottingOptions), (figNum));


sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(dilation_robustness_matrix));

% Check variable sizes
Npoints = size(vgraph,1);
assert(size(dilation_robustness_matrix,1)==Npoints); 
assert(size(dilation_robustness_matrix,1)==Npoints); 

% Check variable values
% Nothing to check

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));


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

%% fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix
function [all_pts, start, finish, vgraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix(dataSetNumber)
% Load some test data
switch dataSetNumber
    case 1
        % Two polytopes with clear space right down middle
        clear polytopes
        polytopes(1).vertices = [0 0; 4,0; 4 2; 2 2.5; 0 0];
        polytopes(2).vertices = [0 -1; 4 -1; 5 -2; 3 -3; 0 -1];
        polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
        goodAxis = [-3 7 -4 4];
        start = [-2 -0.5];
        finish = start;
        finish(1) = 6;

        % Make sure all have same cost
        for ith_poly = 1:length(polytopes)
            polytopes(ith_poly).cost = 0.4;
        end

        point_tot = length([polytopes.xv]); % total number of vertices in the polytopes
        beg_end = zeros(1,point_tot); % is the point the start/end of an obstacle
        curpt = 0;
        for poly = 1:size(polytopes,2) % check each polytope
            verts = length(polytopes(poly).xv);
            polytopes(poly).obs_id = ones(1,verts)*poly; % obs_id is the same for every vertex on a single polytope
            beg_end([curpt+1,curpt+verts]) = 1; % the first and last vertices are marked with 1 and all others are 0
            curpt = curpt+verts;
        end
        obs_id = [polytopes.obs_id];
        all_pts = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(all_pts,1)+1 -1 1];
        finish = [finish size(all_pts,1)+2 -1 1];

        finishes = [all_pts; start; finish];
        starts = [all_pts; start; finish];
        isConcave = 1;
        [vgraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vgraph, [all_pts; start; finish], 'g-');
    case 2
        % Three polytopes with clear space right down middle
        clear polytopes
        polytopes(1).vertices = [0 0; 4,0; 4 1; 1 1; 0 0];
        polytopes(2).vertices = [1.5 1.5; 4 1.5; 4 2; 2 2.5; 1.5 1.5];
        polytopes(3).vertices = [0 -1; 4 -1; 3 -3; 0 -1];
        polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
        goodAxis = [-3 7 -4 4];


        start = [-2 1.25];
        finish = start;
        finish(1) = 6;

        % Make sure all have same cost
        for ith_poly = 1:length(polytopes)
            polytopes(ith_poly).cost = 0.4;
        end

        point_tot = length([polytopes.xv]); % total number of vertices in the polytopes
        beg_end = zeros(1,point_tot); % is the point the start/end of an obstacle
        curpt = 0;
        for poly = 1:size(polytopes,2) % check each polytope
            verts = length(polytopes(poly).xv);
            polytopes(poly).obs_id = ones(1,verts)*poly; % obs_id is the same for every vertex on a single polytope
            beg_end([curpt+1,curpt+verts]) = 1; % the first and last vertices are marked with 1 and all others are 0
            curpt = curpt+verts;
        end
        obs_id = [polytopes.obs_id];
        all_pts = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(all_pts,1)+1 -1 1];
        finish = [finish size(all_pts,1)+2 -1 1];

        finishes = [all_pts; start; finish];
        starts = [all_pts; start; finish];
        isConcave = 1;
        [vgraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vgraph, [all_pts; start; finish], 'g-');
    case 3 % Three polytopes for MECC paper
        clear polytopes
        polytopes(1).vertices = [-10 5; 2 2; -5 -5; -10 5];
        polytopes(2).vertices = [-1 -10; 10 2; 30 2; 40 -10; -1 -10];
        polytopes(3).vertices = [9 7; 7 15; 35 15; 30 7; 9 7];
        
        polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
        goodAxis = [-20 50 -15 20];
        start = [nan nan]; % [-15 5];
        finish = [nan nan]; %[45 5];

        % Make sure all have same cost
        for ith_poly = 1:length(polytopes)
            polytopes(ith_poly).cost = 0.4;
        end

        point_tot = length([polytopes.xv]); % total number of vertices in the polytopes
        beg_end = zeros(1,point_tot); % is the point the start/end of an obstacle
        curpt = 0;
        for poly = 1:size(polytopes,2) % check each polytope
            verts = length(polytopes(poly).xv);
            polytopes(poly).obs_id = ones(1,verts)*poly; % obs_id is the same for every vertex on a single polytope
            beg_end([curpt+1,curpt+verts]) = 1; % the first and last vertices are marked with 1 and all others are 0
            curpt = curpt+verts;
        end
        obs_id = [polytopes.obs_id];
        all_pts = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(all_pts,1)+1 -1 1];
        finish = [finish size(all_pts,1)+2 -1 1];

        finishes = [all_pts; start; finish];
        starts = [all_pts; start; finish];
        isConcave = 1;
        [vgraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vgraph, [all_pts; start; finish], 'g-');
        % Plot the polytopes
        figNum = gcf().Number;
        fcn_INTERNAL_plotPolytopes(polytopes, figNum)

    case 4 % Three rectangles, MECC presentation
        % OLD test case 2, called "Stacked sets of squares"

        clear polytopes
        polytopes(1).vertices = [0 0; 10 0; 10 1; 0 1; 0 0];
        polytopes(2).vertices = polytopes(1).vertices+[0,2];
        polytopes(3).vertices = polytopes(1).vertices+[0,5];
        polytopes(4).vertices = polytopes(1).vertices+[0,10];
        
        polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
        goodAxis = [-5 15 -5 15];
        start = [-3,8];
        finish = [13, 8];

        % Make sure all have same cost
        for ith_poly = 1:length(polytopes)
            polytopes(ith_poly).cost = 0.4;
        end

        point_tot = length([polytopes.xv]); % total number of vertices in the polytopes
        beg_end = zeros(1,point_tot); % is the point the start/end of an obstacle
        curpt = 0;
        for poly = 1:size(polytopes,2) % check each polytope
            verts = length(polytopes(poly).xv);
            polytopes(poly).obs_id = ones(1,verts)*poly; % obs_id is the same for every vertex on a single polytope
            beg_end([curpt+1,curpt+verts]) = 1; % the first and last vertices are marked with 1 and all others are 0
            curpt = curpt+verts;
        end
        obs_id = [polytopes.obs_id];
        all_pts = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(all_pts,1)+1 -1 1];
        finish = [finish size(all_pts,1)+2 -1 1];

        finishes = [all_pts; start; finish];
        starts = [all_pts; start; finish];
        isConcave = 1;
        [vgraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vgraph, [all_pts; start; finish], 'g-');
        % Plot the polytopes
        figNum = gcf().Number;
        fcn_INTERNAL_plotPolytopes(polytopes, figNum)

end % Ends switch
end % Ends fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix


%% fcn_INTERNAL_plotPolytopes
function fcn_INTERNAL_plotPolytopes(polytopes, figNum)
% A wrapper function for plotPolytopes, to plot the polytopes with same
% format

% axes_limits = [0 1 0 1]; % x and y axes limits
% axis_style = 'square'; % plot axes style
plotFormat.Color = 'Blue'; % edge line plotting
plotFormat.LineStyle = '-';
plotFormat.LineWidth = 2; % linewidth of the edge
fillFormat = [1 0 0 1 0.4];
% FORMAT: fcn_MapGen_plotPolytopes(polytopes,figNum,line_spec,line_width,axes_limits,axis_style);
fcn_MapGen_plotPolytopes(polytopes,(plotFormat),(fillFormat),(figNum));
hold on
box on
% axis([-0.1 1.1 -0.1 1.1]);
xlabel('x [m]');
ylabel('y [m]');
end % Ends fcn_INTERNAL_plotPolytopes

%% fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph
function [vGraph, pointsWithData_with_startfinish, goodAxis, polytopes, start, finish, addNudge] = ...
    fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph(test_case_idx)
addNudge = 0.35;
if test_case_idx == 1
    % test case 1
    % Two polytopes with clear space right down middle
    clear polytopes
    polytopes(1).vertices = [0 0; 4,0; 4 2; 2 2.5; 0 0];
    polytopes(2).vertices = [0 -1; 4 -1; 5 -2; 3 -3; 0 -1];
    polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
    goodAxis = [-3 7 -4 4];
    start = [-2 -0.5];
    finish = start;
    finish(1) = 6;
end
if test_case_idx == 2
    % test case 2
    % Stacked sets of squares
    clear polytopes
    polytopes(1).vertices = [0 0; 10 0; 10 1; 0 1; 0 0];
    polytopes(2).vertices = polytopes(1).vertices+[0,2];
    polytopes(3).vertices = polytopes(1).vertices+[0,5];
    polytopes(4).vertices = polytopes(1).vertices+[0,10];
    polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
    start = [0,9];
    finish = start + [10,0];
end

% Make sure all have same cost
for ith_poly = 1:length(polytopes)
    polytopes(ith_poly).cost = 0.4;
end

point_tot = length([polytopes.xv]); % total number of vertices in the polytopes
beg_end = zeros(1,point_tot); % is the point the start/end of an obstacle
curpt = 0;
for poly = 1:size(polytopes,2) % check each polytope
    verts = length(polytopes(poly).xv);
    polytopes(poly).obs_id = ones(1,verts)*poly; % obs_id is the same for every vertex on a single polytope
    beg_end([curpt+1,curpt+verts]) = 1; % the first and last vertices are marked with 1 and all others are 0
    curpt = curpt+verts;
end
obs_id = [polytopes.obs_id];
pointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

start = [start size(pointsWithData,1)+1 -1 1]; 
finish = [finish size(pointsWithData,1)+2 -1 1]; 
pointsWithData_with_startfinish = [pointsWithData; start; finish];

% finishes = [pointsWithData; start; finish];
% starts = [pointsWithData; start; finish];
[vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, pointsWithData_with_startfinish, pointsWithData_with_startfinish,1);


end % Ends fcn_INTERNAL_loadExampleData_fcn_VGraph_plotVGraph






%% function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
function fcn_INTERNAL_clearUtilitiesFromPathAndFolders
% Clear out the variables
clear global flag* FLAG*
clear flag*
clear path

% Clear out any path directories under Utilities
path_dirs = regexp(path,'[;]','split');
utilities_dir = fullfile(pwd,filesep,'Utilities');
for ith_dir = 1:length(path_dirs)
    utility_flag = strfind(path_dirs{ith_dir},utilities_dir);
    if ~isempty(utility_flag)
        rmpath(path_dirs{ith_dir});
    end
end

% Delete the Utilities folder, to be extra clean!
if  exist(utilities_dir,'dir')
    [status,message,message_ID] = rmdir(utilities_dir,'s');
    if 0==status
        error('Unable remove directory: %s \nReason message: %s \nand message_ID: %s\n',utilities_dir, message,message_ID);
    end
end

end % Ends fcn_INTERNAL_clearUtilitiesFromPathAndFolders

%% fcn_INTERNAL_initializeUtilities
function  fcn_INTERNAL_initializeUtilities(library_name,library_folders,library_url,this_project_folders)
% Reset all flags for installs to empty
clear global FLAG*

fprintf(1,'Installing utilities necessary for code ...\n');

% Dependencies and Setup of the Code
% This code depends on several other libraries of codes that contain
% commonly used functions. We check to see if these libraries are installed
% into our "Utilities" folder, and if not, we install them and then set a
% flag to not install them again.

% Set up libraries
for ith_library = 1:length(library_name)
    dependency_name = library_name{ith_library};
    dependency_subfolders = library_folders{ith_library};
    dependency_url = library_url{ith_library};

    fprintf(1,'\tAdding library: %s ...',dependency_name);
    fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url);
    clear dependency_name dependency_subfolders dependency_url
    fprintf(1,'Done.\n');
end

% Set dependencies for this project specifically
fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders);

disp('Done setting up libraries, adding each to MATLAB path, and adding current repo folders to path.');
end % Ends fcn_INTERNAL_initializeUtilities


function fcn_INTERNAL_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url, varargin)
%% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES - MATLAB package installer from URL
%
% FCN_DEBUGTOOLS_INSTALLDEPENDENCIES installs code packages that are
% specified by a URL pointing to a zip file into a default local subfolder,
% "Utilities", under the root folder. It also adds either the package
% subfoder or any specified sub-subfolders to the MATLAB path.
%
% If the Utilities folder does not exist, it is created.
%
% If the specified code package folder and all subfolders already exist,
% the package is not installed. Otherwise, the folders are created as
% needed, and the package is installed.
%
% If one does not wish to put these codes in different directories, the
% function can be easily modified with strings specifying the
% desired install location.
%
% For path creation, if the "DebugTools" package is being installed, the
% code installs the package, then shifts temporarily into the package to
% complete the path definitions for MATLAB. If the DebugTools is not
% already installed, an error is thrown as these tools are needed for the
% path creation.
%
% Finally, the code sets a global flag to indicate that the folders are
% initialized so that, in this session, if the code is called again the
% folders will not be installed. This global flag can be overwritten by an
% optional flag input.
%
% FORMAT:
%
%      fcn_DebugTools_installDependencies(...
%           dependency_name, ...
%           dependency_subfolders, ...
%           dependency_url)
%
% INPUTS:
%
%      dependency_name: the name given to the subfolder in the Utilities
%      directory for the package install
%
%      dependency_subfolders: in addition to the package subfoder, a list
%      of any specified sub-subfolders to the MATLAB path. Leave blank to
%      add only the package subfolder to the path. See the example below.
%
%      dependency_url: the URL pointing to the code package.
%
%      (OPTIONAL INPUTS)
%      flag_force_creation: if any value other than zero, forces the
%      install to occur even if the global flag is set.
%
% OUTPUTS:
%
%      (none)
%
% DEPENDENCIES:
%
%      This code will automatically get dependent files from the internet,
%      but of course this requires an internet connection. If the
%      DebugTools are being installed, it does not require any other
%      functions. But for other packages, it uses the following from the
%      DebugTools library: fcn_DebugTools_addSubdirectoriesToPath
%
% EXAMPLES:
%
% % Define the name of subfolder to be created in "Utilities" subfolder
% dependency_name = 'DebugTools_v2023_01_18';
%
% % Define sub-subfolders that are in the code package that also need to be
% % added to the MATLAB path after install; the package install subfolder
% % is NOT added to path. OR: Leave empty ({}) to only add
% % the subfolder path without any sub-subfolder path additions.
% dependency_subfolders = {'Functions','Data'};
%
% % Define a universal resource locator (URL) pointing to the zip file to
% % install. For example, here is the zip file location to the Debugtools
% % package on GitHub:
% dependency_url = 'https://github.com/ivsg-psu/Errata_Tutorials_DebugTools/blob/main/Releases/DebugTools_v2023_01_18.zip?raw=true';
%
% % Call the function to do the install
% fcn_DebugTools_installDependencies(dependency_name, dependency_subfolders, dependency_url)
%
% This function was written on 2023_01_23 by S. Brennan
% Questions or comments? sbrennan@psu.edu

% Revision history:
% 2023_01_23:
% -- wrote the code originally
% 2023_04_20:
% -- improved error handling
% -- fixes nested installs automatically

% TO DO
% -- Add input argument checking

flag_do_debug = 0; % Flag to show the results for debugging
flag_do_plots = 0; % % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(3,4);
end

%% Set the global variable - need this for input checking
% Create a variable name for our flag. Stylistically, global variables are
% usually all caps.
flag_varname = upper(cat(2,'flag_',dependency_name,'_Folders_Initialized'));

% Make the variable global
eval(sprintf('global %s',flag_varname));

if nargin==4
    if varargin{1}
        eval(sprintf('clear global %s',flag_varname));
    end
end

%% Main code starts here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~exist(flag_varname,'var') || isempty(eval(flag_varname))
    % Save the root directory, so we can get back to it after some of the
    % operations below. We use the Print Working Directory command (pwd) to
    % do this. Note: this command is from Unix/Linux world, but is so
    % useful that MATLAB made their own!
    root_directory_name = pwd;

    % Does the directory "Utilities" exist?
    utilities_folder_name = fullfile(root_directory_name,'Utilities');
    if ~exist(utilities_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(root_directory_name,'Utilities');

        % Did it work?
        if ~success_flag
            error('Unable to make the Utilities directory. Reason: %s with message ID: %s\n',error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The Utilities directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',error_message, message_ID);
        end

    end

    % Does the directory for the dependency folder exist?
    dependency_folder_name = fullfile(root_directory_name,'Utilities',dependency_name);
    if ~exist(dependency_folder_name,'dir')
        % If we are in here, the directory does not exist. So create it
        % using mkdir
        [success_flag,error_message,message_ID] = mkdir(utilities_folder_name,dependency_name);

        % Did it work?
        if ~success_flag
            error('Unable to make the dependency directory: %s. Reason: %s with message ID: %s\n',dependency_name, error_message,message_ID);
        elseif ~isempty(error_message)
            warning('The %s directory was created, but with a warning: %s\n and message ID: %s\n(continuing)\n',dependency_name, error_message, message_ID);
        end

    end

    % Do the subfolders exist?
    flag_allFoldersThere = 1;
    if isempty(dependency_subfolders{1})
        flag_allFoldersThere = 0;
    else
        for ith_folder = 1:length(dependency_subfolders)
            subfolder_name = dependency_subfolders{ith_folder};

            % Create the entire path
            subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

            % Check if the folder and file exists that is typically created when
            % unzipping.
            if ~exist(subfunction_folder,'dir')
                flag_allFoldersThere = 0;
            end
        end
    end

    % Do we need to unzip the files?
    if flag_allFoldersThere==0
        % Files do not exist yet - try unzipping them.
        save_file_name = tempname(root_directory_name);
        zip_file_name = websave(save_file_name,dependency_url);
        % CANT GET THIS TO WORK --> unzip(zip_file_url, debugTools_folder_name);

        % Is the file there?
        if ~exist(zip_file_name,'file')
            error(['The zip file: %s for dependency: %s did not download correctly.\n' ...
                'This is usually because permissions are restricted on ' ...
                'the current directory. Check the code install ' ...
                '(see README.md) and try again.\n'],zip_file_name, dependency_name);
        end

        % Try unzipping
        unzip(zip_file_name, dependency_folder_name);

        % Did this work? If so, directory should not be empty
        directory_contents = dir(dependency_folder_name);
        if isempty(directory_contents)
            error(['The necessary dependency: %s has an error in install ' ...
                'where the zip file downloaded correctly, ' ...
                'but the unzip operation did not put any content ' ...
                'into the correct folder. ' ...
                'This suggests a bad zip file or permissions error ' ...
                'on the local computer.\n'],dependency_name);
        end

        % Check if is a nested install (for example, installing a folder
        % "Toolsets" under a folder called "Toolsets"). This can be found
        % if there's a folder whose name contains the dependency_name
        flag_is_nested_install = 0;
        for ith_entry = 1:length(directory_contents)
            if contains(directory_contents(ith_entry).name,dependency_name)
                if directory_contents(ith_entry).isdir
                    flag_is_nested_install = 1;
                    install_directory_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name);
                    install_files_from = fullfile(directory_contents(ith_entry).folder,directory_contents(ith_entry).name,'*.*');
                    install_location_to = fullfile(directory_contents(ith_entry).folder);
                end
            end
        end

        if flag_is_nested_install
            [status,message,message_ID] = movefile(install_files_from,install_location_to);
            if 0==status
                error(['Unable to move files from directory: %s\n ' ...
                    'To: %s \n' ...
                    'Reason message: %s\n' ...
                    'And message_ID: %s\n'],install_files_from,install_location_to, message,message_ID);
            end
            [status,message,message_ID] = rmdir(install_directory_from);
            if 0==status
                error(['Unable remove directory: %s \n' ...
                    'Reason message: %s \n' ...
                    'And message_ID: %s\n'],install_directory_from,message,message_ID);
            end
        end

        % Make sure the subfolders were created
        flag_allFoldersThere = 1;
        if ~isempty(dependency_subfolders{1})
            for ith_folder = 1:length(dependency_subfolders)
                subfolder_name = dependency_subfolders{ith_folder};

                % Create the entire path
                subfunction_folder = fullfile(root_directory_name, 'Utilities', dependency_name,subfolder_name);

                % Check if the folder and file exists that is typically created when
                % unzipping.
                if ~exist(subfunction_folder,'dir')
                    flag_allFoldersThere = 0;
                end
            end
        end
        % If any are not there, then throw an error
        if flag_allFoldersThere==0
            error(['The necessary dependency: %s has an error in install, ' ...
                'or error performing an unzip operation. The subfolders ' ...
                'requested by the code were not found after the unzip ' ...
                'operation. This suggests a bad zip file, or a permissions ' ...
                'error on the local computer, or that folders are ' ...
                'specified that are not present on the remote code ' ...
                'repository.\n'],dependency_name);
        else
            % Clean up the zip file
            delete(zip_file_name);
        end

    end


    % For path creation, if the "DebugTools" package is being installed, the
    % code installs the package, then shifts temporarily into the package to
    % complete the path definitions for MATLAB. If the DebugTools is not
    % already installed, an error is thrown as these tools are needed for the
    % path creation.
    %
    % In other words: DebugTools is a special case because folders not
    % added yet, and we use DebugTools for adding the other directories
    if strcmp(dependency_name(1:10),'DebugTools')
        debugTools_function_folder = fullfile(root_directory_name, 'Utilities', dependency_name,'Functions');

        % Move into the folder, run the function, and move back
        cd(debugTools_function_folder);
        fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        cd(root_directory_name);
    else
        try
            fcn_DebugTools_addSubdirectoriesToPath(dependency_folder_name,dependency_subfolders);
        catch
            error(['Package installer requires DebugTools package to be ' ...
                'installed first. Please install that before ' ...
                'installing this package']);
        end
    end


    % Finally, the code sets a global flag to indicate that the folders are
    % initialized.  Check this using a command "exist", which takes a
    % character string (the name inside the '' marks, and a type string -
    % in this case 'var') and checks if a variable ('var') exists in matlab
    % that has the same name as the string. The ~ in front of exist says to
    % do the opposite. So the following command basically means: if the
    % variable named 'flag_CodeX_Folders_Initialized' does NOT exist in the
    % workspace, run the code in the if statement. If we look at the bottom
    % of the if statement, we fill in that variable. That way, the next
    % time the code is run - assuming the if statement ran to the end -
    % this section of code will NOT be run twice.

    eval(sprintf('%s = 1;',flag_varname));
end

%% Plot the results (for debugging)?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots

    % Nothing to do!



end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends function fcn_DebugTools_installDependencies
