% script_test_fcn_VGraph_helperFillPolytopesFromPointData
% Tests: fcn_VGraph_helperFillPolytopesFromPointData

% REVISION HISTORY:
% As: script_test_fcn_VGraph_helperFillPolytopesFromPointData
% 2025_11_16 by S. Brennan
% - first write of script, using script_test_fcn_VGraph_costCalculate as
%   % template

% TO DO:
% - (fill in here)


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

%% DEMO case: Two polytopes with clear space right down middle, basic example
figNum = 10001;
titleString = sprintf('DEMO case: Two polytopes with clear space right down middle, basic example');
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

%% TEST case: Two polytopes with clear space right down middle, "movement distance" test
figNum = 20001;
titleString = sprintf('TEST case: Two polytopes with clear space right down middle, cost calculation based on "movement distance"');
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

% Load some test data 
dataSetNumber = 1; % Two polytopes with clear space right down middle
[pointsWithData, ~, ~, ~] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber);


% Call the function
polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, ([]));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isstruct(polytopes));

% Check variable sizes
assert(size(polytopes,1)==1); 
assert(size(polytopes,2)==2); 

% Check variable values
% Nothing to check here

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Basic fast mode - NO FIGURE, FAST MODE
figNum = 80002;
fprintf(1,'Figure: %.0f: FAST mode, figNum=-1\n',figNum);
figure(figNum); close(figNum);

% Load some test data 
dataSetNumber = 1; % Two polytopes with clear space right down middle
[pointsWithData, ~, ~, ~] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber);


% Call the function
polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, (-1));

sgtitle(titleString, 'Interpreter','none');

% Check variable types
assert(isstruct(polytopes));

% Check variable sizes
assert(size(polytopes,1)==1); 
assert(size(polytopes,2)==2); 

% Check variable values
% Nothing to check here

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


%% Compare speeds of pre-calculation versus post-calculation versus a fast variant
figNum = 80003;
fprintf(1,'Figure: %.0f: FAST mode comparisons\n',figNum);
figure(figNum);
close(figNum);

% Load some test data 
dataSetNumber = 1; % Two polytopes with clear space right down middle
[pointsWithData, ~, ~, ~] = fcn_INTERNAL_loadExampleData_costCalculate(dataSetNumber);
 
Niterations = 10;

% Do calculation without pre-calculation
tic;
for ith_test = 1:Niterations
    % Call the function
    polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, ([]));

end
slow_method = toc;

% Do calculation with pre-calculation, FAST_MODE on2025_04
tic;
for ith_test = 1:Niterations
    % Call the function
    polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, (-1));

end
fast_method = toc;

% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));

% Plot results as bar chart
figure(373737);
clf;
hold on;

X = categorical({'Normal mode','Fast mode'});
X = reordercats(X,{'Normal mode','Fast mode'}); % Forces bars to appear in this exact order, not alphabetized
Y = [slow_method fast_method ]*1000/Niterations;
bar(X,Y)
ylabel('Execution time (Milliseconds)')


% Make sure plot did NOT open up
figHandles = get(groot, 'Children');
assert(~any(figHandles==figNum));


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

function INTERNAL_plot_results(tempXYdata,cell_array_of_entry_indices,cell_array_of_lap_indices,cell_array_of_exit_indices,figNum) %#ok<DEFNU>
figure(figNum);
clf

% Make first subplot
subplot(1,3,1);  
axis square
hold on;
title('Laps');
legend_text = {};
    
for ith_lap = 1:length(cell_array_of_lap_indices)
    plot(tempXYdata(cell_array_of_lap_indices{ith_lap},1),tempXYdata(cell_array_of_lap_indices{ith_lap},2),'.-','Linewidth',3);
    legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
end
h_legend = legend(legend_text);
set(h_legend,'AutoUpdate','off');
temp1 = axis;

% Make second subplot
subplot(1,3,2);  
axis square
hold on;
title('Entry');
legend_text = {};
    
for ith_lap = 1:length(cell_array_of_entry_indices)
    plot(tempXYdata(cell_array_of_entry_indices{ith_lap},1),tempXYdata(cell_array_of_entry_indices{ith_lap},2),'.-','Linewidth',3);
    legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
end
h_legend = legend(legend_text);
set(h_legend,'AutoUpdate','off');
temp2 = axis;

% Make third subplot
subplot(1,3,3);  
axis square
hold on;
title('Exit');
legend_text = {};
    
for ith_lap = 1:length(cell_array_of_exit_indices)
    plot(tempXYdata(cell_array_of_exit_indices{ith_lap},1),tempXYdata(cell_array_of_exit_indices{ith_lap},2),'.-','Linewidth',3);
    legend_text = [legend_text, sprintf('Lap %d',ith_lap)]; %#ok<AGROW>    
end
h_legend = legend(legend_text);
set(h_legend,'AutoUpdate','off');
temp3 = axis;

% Set all axes to same value, maximum range
max_axis = max([temp1; temp2; temp3]);
min_axis = min([temp1; temp2; temp3]);
good_axis = [min_axis(1) max_axis(2) min_axis(3) max_axis(4)];
subplot(1,3,1); axis(good_axis);
subplot(1,3,2); axis(good_axis);
subplot(1,3,3); axis(good_axis);


end

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
