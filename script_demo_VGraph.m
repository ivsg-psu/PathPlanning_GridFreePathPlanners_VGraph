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
% - created a the repo by removing visibility functions out of the
%    % BoundedAStar repo
% 2025_11_07
% - fix bug with hardcoded expected vGraphs in
%    script_test_fcn_VGraph_clearAndBlockedPointsGlobal
% - added fast mode test cases for all scropts
% 2025_11_08 - S. Brennan
% - updated variable naming:
%    % * fig_num to figNum
%    % * vg+raph to vGraph
%    % * all_+pts to pointsWithData
%    % * sta+rt to startPointData or startXY, depending on usage
%    % * fi+nish to finishPointData or finishXY, depending on usage
% - fixed minor MATLAB warnings
% 2025_11_12 - S. Brennan
% - set up auto-loading of dependencies using new DebugTools features
% - fixed minor "laps" issues in README
% - fixed minor test script bugs so that all run through cleanly
% (new release)
%
% 2025_11_13 - S. Brennan
% - updated script_test_all_functions
% - updated header flags for clearing path, to do fast checking without
%   % skipping
% (new release)
%
% 2025_11_14 - S. Brennan
% - cleaned up formatting of this demo
% - added fcn_VGraph_polytopePointsInPolytopes
%   % * pulled from BoundedAStar library
%   % * updated README.md
% (in script_test_fcn_VGraph_polytopePointsInPolytopes)
% - renamed script after moving from BoundedAStar repo
%   % * from script_test_fcn_BoundedAStar_polytopePointsInPolytopes
%   % * to script_test_fcn_VGraph_polytopePointsInPolytopes
% - fixed header listing of script name - it was incorrect!
% (new release)
%
% 2025_11_14 - S. Brennan
% - cleaned up formatting of this demo
%
% 2025_11_17 - S. Brennan
% - Updated formatting to Markdown on Rev history in all functions
% - Cleaned up variable naming in all functions
%   % fig+_num to figNum
%   % vis+ibilityMatrix to vGraph
%   % newVi+sibilityMatrix to newVGraph
%   % all_+pts to pointsWithData
%   % cos+tGraph to cGraph
%   % vgra+ph to vGraph
%   % visib+ilityGraph to vGraph
% - Added fcn_VGraph_costCalculate function
% - Updated README.md
% (new release)
%
% 2025_11_18 - S. Brennan
% - Added fcn_VGraph_helperFillPolytopesFromPointData function
% - Updated README.md
% - In fcn_VGraph_costCalculate
%   % * Updated dependencies list
% (new release)



% TO-DO:
% 2025_11_17 - Sean Brennan, sbrennan@psu.edu
% - In: fcn_VGraph_costCalculate
%   % * need to add total distance of "to" point to goal as an option
%   % * then, show in Greedy planner that this produces Djkstra's algorithm
% - Need to figure out what findEdgeWeights does, and fix, finish, or
%   % delete
% - Need to deprecate functions to make classes of functions more clear:
%   % * Classes would be: plot, cost, visibility, modify, support?
%   % * modify(VisibilityObstacleAdd)

%% Check which files contain key strings?
if 1==1
    clc
    functionsDirectoryQuery = fullfile(pwd,'Functions','*.*');
    % Use the following instead, if wish to do subdirectories
    % directoryQuery = fullfile(pwd,'Functions','**','*.*');

    fileListFunctionsFolder = dir(functionsDirectoryQuery); %cat(2,'.',filesep,filesep,'script_test_fcn_*.m'));

    % Filter out directories from the list
    fileListFunctionsFolderNoDirectories = fileListFunctionsFolder(~[fileListFunctionsFolder.isdir]);

    % Make sure there's not fig_num
    queryString = 'visibilityGraph';
    flagsStringWasFoundInFilesRaw = fcn_DebugTools_directoryStringQuery(fileListFunctionsFolderNoDirectories, queryString, (-1));
    % flagsStringWasFoundInFiles = fcn_INTERNAL_removeFromList(flagsStringWasFoundInFilesRaw, fileListFunctionsFolderNoDirectories,'script_test_all_functions');
    if sum(flagsStringWasFoundInFilesRaw)>0
        fcn_DebugTools_directoryStringQuery(fileListFunctionsFolderNoDirectories, queryString, 1);
        error('A "%s" was found in one of the functions - see listing above.', queryString);
    end
end

%% Make sure we are running out of root directory
st = dbstack; 
thisFile = which(st(1).file);
[filepath,name,ext] = fileparts(thisFile);
cd(filepath);

%% Clear paths and folders, if needed
if 1==1
    clear flag_VGraph_Folders_Initialized
end
if 1==0
    fcn_INTERNAL_clearUtilitiesFromPathAndFolders;
end

%% Install dependencies
% Define a universal resource locator (URL) pointing to the repos of
% dependencies to install. Note that DebugTools is always installed
% automatically, first, even if not listed:
clear dependencyURLs dependencySubfolders
ith_repo = 0;

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_MapTools_MapGenClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','testFixtures','GridMapGen'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_PathTools_PathClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/FieldDataCollection_VisualizingFieldData_PlotRoad';
dependencySubfolders{ith_repo} = {'Functions','Data'};

ith_repo = ith_repo+1;
dependencyURLs{ith_repo} = 'https://github.com/ivsg-psu/PathPlanning_GeomTools_GeomClassLibrary';
dependencySubfolders{ith_repo} = {'Functions','Data'};

%% Do we need to set up the work space?
if ~exist('flag_VGraph_Folders_Initialized','var')

    % Clear prior global variable flags
    clear global FLAG_*

    % Navigate to the Installer directory
    currentFolder = pwd;
    cd('Installer');
    % Create a function handle
    func_handle = @fcn_DebugTools_autoInstallRepos;

    % Return to the original directory
    cd(currentFolder);

    % Call the function to do the install
    func_handle(dependencyURLs, dependencySubfolders, (0), (-1));

    % Add this function's folders to the path
    this_project_folders = {...
        'Functions','Data'};
    fcn_DebugTools_addSubdirectoriesToPath(pwd,this_project_folders)

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
% Figures start with 1

close all;
fprintf(1,'Figure: 1XXXXXX: PLOTTING functions\n');

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


%% Supporting functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                              _   _               ______                _   _
%  / ____|                            | | (_)             |  ____|              | | (_)
% | (___  _   _ _ __  _ __   ___  _ __| |_ _ _ __   __ _  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  \___ \| | | | '_ \| '_ \ / _ \| '__| __| | '_ \ / _` | |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  ____) | |_| | |_) | |_) | (_) | |  | |_| | | | | (_| | | |  | |_| | | | | (__| |_| | (_) | | | \__ \
% |_____/ \__,_| .__/| .__/ \___/|_|   \__|_|_| |_|\__, | |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%              | |   | |                            __/ |
%              |_|   |_|                           |___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Supporting+Functions&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


close all;
fprintf(1,'Figure: 2XXXXXX: SUPPORTING functions\n');

%% fcn_VGraph_polytopesGenerateAllPtsTable
% The following is test case 10001 in the test script
figNum = 20001;
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
figNum = 20002;
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
fig_num = 20003;
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
    
    pointsWithDataRaw = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes,start_xy,finish_xy,-1);
    % Remove start and end
    pointsWithData = pointsWithDataRaw(1:end-2,:);
    
    %%%%%

    save(fullPath,'polytopes','pointsWithData','gapSize');

end

% Calculate weighted visibility graph (cost graph)
[costGraph, vGraph] = fcn_VGraph_findEdgeWeights(polytopes, pointsWithData, gapSize, fig_num);

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(costGraph));
assert(isnumeric(vGraph));

% Check variable sizes
Npoly = 5;
assert(isequal(Npoly,length(polytopes))); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),fig_num));

%% fcn_VGraph_selfBlockedPoints
% This is case 10001 in test script
figNum = 20004;
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

% Note: this includes start/finish points now
pointsWithData = fcn_VGraph_polytopesGenerateAllPtsTable(polytopes, startXY, finishXY,-1);

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

%% fcn_VGraph_polytopePointsInPolytopes
% This is test 10002 in the script
figNum = 20005;
titleString = sprintf('fcn_VGraph_polytopePointsInPolytopes');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Set up polytopes

% Use tiling to generate 8 polytopes
startingIndex = 345;
fullyTiledPolytopes = fcn_MapGen_generatePolysFromSeedGeneratorNames('haltonset', [startingIndex startingIndex+7], ([]), ([10 10]), -1);

% Trim polytopes along edge
trimmedPolytopes = fcn_MapGen_polytopesDeleteByAABB( fullyTiledPolytopes, [0 0 100 100], (-1));

% Shrink polytopes to form obstacles
polytopes = fcn_MapGen_polytopesShrinkEvenly(trimmedPolytopes, 0.75, (-1));

% Set up many sample points
Npoints = 20;
startXY = rand(Npoints,2)*10;
finishXY = rand(Npoints,2)*10;

flagThrowError = 0;
flagEdgeCheck = 0;

[flagsAtLeastOnePointIsInPoly, startPolys, finishPolys, flagsStartIsInPoly, flagsFinishIsInPoly] = ...
    fcn_VGraph_polytopePointsInPolytopes( ...
    startXY, finishXY, polytopes, ...
    (flagThrowError), (flagEdgeCheck), (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(islogical(flagsAtLeastOnePointIsInPoly));
assert(isnumeric(startPolys));
assert(isnumeric(finishPolys));
assert(islogical(flagsStartIsInPoly));
assert(islogical(flagsFinishIsInPoly));

% Check variable sizes
Npoints = length(startXY(:,1));
assert(size(flagsAtLeastOnePointIsInPoly,1)==Npoints); 
assert(size(flagsAtLeastOnePointIsInPoly,2)==1); 
assert(size(startPolys,1)==Npoints); 
assert(size(startPolys,2)==1); 
assert(size(finishPolys,1)==Npoints); 
assert(size(finishPolys,2)==1); 
assert(size(flagsStartIsInPoly,1)==Npoints); 
assert(size(flagsStartIsInPoly,2)==1); 
assert(size(flagsFinishIsInPoly,1)==Npoints); 
assert(size(flagsFinishIsInPoly,2)==1); 

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

close all;
fprintf(1,'Figure: 3XXXXXX: CORE functions\n');


%% fcn_VGraph_clearAndBlockedPoints
% This is the first demo case in the script: find clear and blocked edges of polytopes in a map
figNum = 30001;
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
figNum = 30002;
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
figNum = 30003;
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
figNum = 30004;
titleString = sprintf('fcn_VGraph_generateDilationRobustnessMatrix');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load some test data 
dataSetNumber = 2; % Two polytopes with clear space right down middle
[pointsWithData, start, finish, vGraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix(dataSetNumber);

% Set options
mode = '2d';

plottingOptions.axis = goodAxis;
plottingOptions.selectedFromToToPlot = []; %[3 7];
plottingOptions.filename = []; % Specify the output file name

% Call the function
dilation_robustness_matrix = ...
    fcn_VGraph_generateDilationRobustnessMatrix(...
    pointsWithData, start, finish, vGraph, mode, polytopes,...
    (plottingOptions), (figNum));


sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(dilation_robustness_matrix));

% Check variable sizes
Npoints = size(vGraph,1);
assert(size(dilation_robustness_matrix,1)==Npoints); 
assert(size(dilation_robustness_matrix,1)==Npoints); 

% Check variable values
% Nothing to check

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

%% Cost functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %   _____          _     ______                _   _                 
 %  / ____|        | |   |  ____|              | | (_)                
 % | |     ___  ___| |_  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
 % | |    / _ \/ __| __| |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
 % | |___| (_) \__ \ |_  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
 %  \_____\___/|___/\__| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Cost+Functions&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
fprintf(1,'Figure: 4XXXXXX: COST functions\n');

%% DEMO case: fcn_VGraph_costCalculate
% This is case 10001 in the test script

figNum = 40001;
titleString = sprintf('fcn_VGraph_costCalculate');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); close(figNum);

% Load some test data 
dataSetNumber = 1; % Two polytopes with clear space right down middle
[pointsWithData, vGraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber);

% Plot the polytopes
fcn_INTERNAL_plotPolytopes(polytopes, figNum)
axis(goodAxis);

modeString = 'distance from finish';

% Call the function
cGraph = ...
    fcn_VGraph_costCalculate(...
    vGraph, pointsWithData, modeString, ...
    (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isnumeric(cGraph));

% Check variable sizes
Npoints = size(vGraph,1);
assert(size(cGraph,1)==Npoints); 
assert(size(cGraph,1)==Npoints); 

% Check variable values
assert(round(max(cGraph(~isinf(cGraph)),[],'all'))==8);
assert(round(min(cGraph(~isinf(cGraph)),[],'all'))==0); 

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

% Save results
fullPathFileName = fullfile(pwd,'Images',cat(2,titleString,'.png'));
saveas(gcf, fullPathFileName);
fullPathFileName = fullfile(pwd,'Images',cat(2,titleString,'.fig'));
saveas(gcf, fullPathFileName);

%% Helper functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  _    _      _                   ______                _   _
% | |  | |    | |                 |  ____|              | | (_)
% | |__| | ___| |_ __   ___ _ __  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
% |  __  |/ _ \ | '_ \ / _ \ '__| |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
% | |  | |  __/ | |_) |  __/ |    | |  | |_| | | | | (__| |_| | (_) | | | \__ \
% |_|  |_|\___|_| .__/ \___|_|    |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%               | |
%               |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Helper+Functions&x=none&v=4&h=4&w=80&we=false
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
fprintf(1,'Figure: 5XXXXXX: HELPER functions\n');

%% DEMO case: fcn_VGraph_helperFillPolytopesFromPointData
% This is case 10001 in the test script

figNum = 50001;
titleString = sprintf('fcn_VGraph_helperFillPolytopesFromPointData');
fprintf(1,'Figure %.0f: %s\n',figNum, titleString);
figure(figNum); clf;

% Load some test data 
dataSetNumber = 1; % Two polytopes with clear space right down middle
[pointsWithData, ~, ~, ~] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber);


% Call the function
polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, (figNum));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isstruct(polytopes));

% Check variable sizes
assert(size(polytopes,1)==1); 
assert(size(polytopes,2)==2); 

% Check variable values
% Nothing to check here

% Make sure plot opened up
assert(isequal(get(gcf,'Number'),figNum));

% Save results
fullPathFileName = fullfile(pwd,'Images',cat(2,titleString,'.png'));
saveas(gcf, fullPathFileName);
fullPathFileName = fullfile(pwd,'Images',cat(2,titleString,'.fig'));
saveas(gcf, fullPathFileName);

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
function [pointsWithData, start, finish, vGraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_generateDilationRobustnessMatrix(dataSetNumber)
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
        pointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(pointsWithData,1)+1 -1 1];
        finish = [finish size(pointsWithData,1)+2 -1 1];

        finishes = [pointsWithData; start; finish];
        starts = [pointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
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
        pointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(pointsWithData,1)+1 -1 1];
        finish = [finish size(pointsWithData,1)+2 -1 1];

        finishes = [pointsWithData; start; finish];
        starts = [pointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
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
        pointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(pointsWithData,1)+1 -1 1];
        finish = [finish size(pointsWithData,1)+2 -1 1];

        finishes = [pointsWithData; start; finish];
        starts = [pointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
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
        pointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(pointsWithData,1)+1 -1 1];
        finish = [finish size(pointsWithData,1)+2 -1 1];

        finishes = [pointsWithData; start; finish];
        starts = [pointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
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


%% fcn_INTERNAL_loadExampleData_costCalculate
function [pointsWithData, vGraph, polytopes, goodAxis] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber)
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
        vertexPointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(vertexPointsWithData,1)+1 -1 1];
        finish = [finish size(vertexPointsWithData,1)+2 -1 1];

        finishes = [vertexPointsWithData; start; finish];
        starts = [vertexPointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
        pointsWithData = starts;
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
        vertexPointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(vertexPointsWithData,1)+1 -1 1];
        finish = [finish size(vertexPointsWithData,1)+2 -1 1];

        finishes = [vertexPointsWithData; start; finish];
        starts = [vertexPointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        % fcn_VGraph_plotVGraph(vGraph, [pointsWithData; start; finish], 'g-');
        pointsWithData = starts;
    case 3 % Three polytopes for MECC paper
        clear polytopes
        polytopes(1).vertices = [-10 5; 2 2; -5 -5; -10 5];
        polytopes(2).vertices = [-1 -10; 10 2; 30 2; 40 -10; -1 -10];
        polytopes(3).vertices = [9 7; 7 15; 35 15; 30 7; 9 7];
        
        polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);
        goodAxis = [-20 50 -15 20];
        start = [-15 5];
        finish = [45 5];

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
        vertexPointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(vertexPointsWithData,1)+1 -1 1];
        finish = [finish size(vertexPointsWithData,1)+2 -1 1];

        finishes = [vertexPointsWithData; start; finish];
        starts = [vertexPointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vGraph, [vertexPointsWithData; start; finish], 'g-');
        % Plot the polytopes
        figNum = gcf().Number;
        fcn_INTERNAL_plotPolytopes(polytopes, figNum)
        pointsWithData = starts;

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
        vertexPointsWithData = [[polytopes.xv];[polytopes.yv];1:point_tot;obs_id;beg_end]'; % all points [x y point_id obs_id beg_end]

        start = [start size(vertexPointsWithData,1)+1 -1 1];
        finish = [finish size(vertexPointsWithData,1)+2 -1 1];

        finishes = [vertexPointsWithData; start; finish];
        starts = [vertexPointsWithData; start; finish];
        isConcave = 1;
        [vGraph, ~] = fcn_VGraph_clearAndBlockedPointsGlobal(polytopes, starts, finishes, isConcave,-1);
        fcn_VGraph_plotVGraph(vGraph, [vertexPointsWithData; start; finish], 'g-');
        % Plot the polytopes
        figNum = gcf().Number;
        fcn_INTERNAL_plotPolytopes(polytopes, figNum)
        pointsWithData = starts;

end % Ends switch
end % Ends fcn_INTERNAL_loadExampleData_costCalculate