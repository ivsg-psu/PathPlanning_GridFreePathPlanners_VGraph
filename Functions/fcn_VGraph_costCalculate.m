function cGraph = ...
    fcn_VGraph_costCalculate(...
    vGraph, pointsWithData, ...
     varargin)
% fcn_VGraph_costCalculate
% given a visibility matrix, details on points, and cost calculation
% method, calculates a cost matrix.
%
% FORMAT:
%
%     cGraph = ...
%         fcn_VGraph_costCalculate(...
%         vGraph, pointsWithData, ...
%         (modeString), (figNum));
%
% INPUTS:
%
%     vGraph: the visibility graph as an nxn matrix where n is the number of
%     points (nodes) in the map. A 1 is in position i,j if point j is
%     visible from point i.  0 otherwise. The vGraph indicates which points
%     are visible from (rows) to (columns) each other.
%
%     pointsWithData: n-by-5 matrix of all the possible to/from points for
%     visibility calculations including the vertex points on each obstacle,
%     and if the user specifies, the start and/or end points. If the
%     start/end points are omitted, the value of p is the same as the
%     number of points within the polytope field, numPolytopeVertices.
%     Otherwise, p is 1 or 2 larger depending on whether start/end is
%     given. The information in the 5 columns is as follows:
%         x-coordinate
%         y-coordinate
%         point id number
%         obstacle id number (-1 for start/end points)
%         beginning/ending indication (1 if the point is a beginning or
%         start point, 2 if ending point or finish point, and 0 otherwise)
%         Ex: [x y point_id obs_id beg_end]
%
%      (OPTIONAL INPUTS)
%
%      modeString: a string allowing user to specify the cost criterion.
%      Allowable values include:
%
%          'distance from finish': the cost of a to/from edge is specified
%          as the distance of the "from" destination to the finish. This is
%          typically the heruistic cost for A-star, greedy, and similar
%          planners.
%
%          'movement distance': the distance between the from and to point
%          on each edge is the cost of the edge. This is the cost according
%          to classic path planners.
% 
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      cGraph: the cost graph. This is the same size as the visibility
%      graph, but instead of 1 values indicating visibility, a cost value
%      is given for each element. For static maps, the visibility graph
%      will not change, but costs may change depending on user-defined
%      cost criteria.
%
% DEPENDENCIES:
%
%      (none)
%
% EXAMPLES:
%
% See the script: script_test_fcn_VGraph_costCalculate
% for a full test suite.
%
% This function was written on 2025_11_16 by Sean Brennan
% Questions or comments? contact sbrennan@psu.edu

% REVISION HISTORY:
% As: fcn_VGraph_costCalculate
% 
% 2025_11_16 - S. Brennan
% - First write of function
%
% 2025_11_17 - S. Brennan
% - Updated formatting to Markdown on Rev history
% - Cleaned up variable naming in all functions
%   % vgra+ph to vGraph

% TO DO:
% - fill in to-do items here.


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 4; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %   %   Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %   %   Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_VGRAPH_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_VGRAPH_FLAG_CHECK_INPUTS");
    MATLABFLAG_VGRAPH_FLAG_DO_DEBUG = getenv("MATLABFLAG_VGRAPH_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_VGRAPH_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_VGRAPH_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_VGRAPH_FLAG_DO_DEBUG);
        flag_check_inputs  = str2double(MATLABFLAG_VGRAPH_FLAG_CHECK_INPUTS);
    end
end

% flag_do_debug = 1;

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
    debug_figNum = 999978; %#ok<NASGU>
end


%% check input arguments?
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

if (0==flag_max_speed)
    if 1 == flag_check_inputs

        % Are there the right number of inputs?
        narginchk(2,MAX_NARGIN);

        % Check the vGraph input. Since it includes start/end, it must have
        % 3 or more columns
        fcn_DebugTools_checkInputsToFunctions(vGraph, '3orMorecolumn_of_numbers');
        % See script_test_fcn_DebugTools_checkInputsToFunctions
        nVertices = size(vGraph,1);
        if nVertices~=size(vGraph,2)
            warning('backtrace','on');
            warning(['The vGraph input is not square. It has %.0d rows and %.0dcolumns. ' ...
                'Throwing error.'],size(vGraph,1), size(vGraph,2));
            error('The input vGraph must be a square matrix.')
        end

        % Check the pointsWithData input. It should have 5 columns,
        % nVertices rows
        fcn_DebugTools_checkInputsToFunctions(pointsWithData, '5column_of_numbers', nVertices);
        vertexIDs = pointsWithData(:,3);
        assert(max(vertexIDs)==nVertices);
        assert(min(vertexIDs)==1);
        assert(all(diff(vertexIDs)>0));

    end
end


% Does user want to specify modeString?
% initialize default values
modeString = 'distance from finish';
if 3 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        modeString = temp;
    end
end

% Does user want to show the plots?
flag_do_plots = 0; % Default is to NOT show plots
figNum = []; % Empty by default
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        figNum = temp;
        flag_do_plots = 1;
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

nVertices = size(vGraph,1);
startXY   = pointsWithData(end-1,1:2);
finishXY  = pointsWithData(end,1:2);



switch lower(modeString)
    case {'distance from finish'}

        % Remove the diagonal terms
        vGraphNoDiagonal = vGraph;
        temp = eye(nVertices);
        vGraphNoDiagonal(temp==1) = 0;

        allPointsXY = pointsWithData(:,1:2);
        distancesToFinish = sum((allPointsXY-finishXY).^2,2).^0.5+1000*eps;
        templateMatrix = vGraph.*repmat(distancesToFinish',nVertices,1);

        if 1==0
            % Another way to generate templateMatrix - not sure if this is
            % faster?
            allPointsXY = pointsWithData(:,1:2);
            distancesToFinish = sum((allPointsXY-finishXY).^2,2).^0.5+1000*eps;
            [~,toIndices] = find(vGraph);
            rawIndices = find(vGraph);
            templateMatrix(rawIndices) = distancesToFinish(toIndices,1); %#ok<FNDSB>
        end

        cGraph = inf(nVertices,nVertices);
        cGraph(vGraphNoDiagonal==1) = templateMatrix(vGraphNoDiagonal==1);
        
    case {'movement distance'}
         % Remove the diagonal terms
        vGraphNoDiagonal = vGraph;
        temp = eye(nVertices);
        vGraphNoDiagonal(temp==1) = 0;

        allPointsXY = pointsWithData(:,1:2);
        [fromIndices,toIndices] = find(vGraphNoDiagonal);
        edgeLengths = sum((allPointsXY(fromIndices,:)-allPointsXY(toIndices,:)).^2,2).^0.5;
        rawIndices = find(vGraphNoDiagonal);
        templateMatrix = nan(nVertices, nVertices);
        templateMatrix(rawIndices) = edgeLengths; %#ok<FNDSB>

        
        cGraph = inf(nVertices,nVertices);
        cGraph(vGraphNoDiagonal==1) = templateMatrix(vGraphNoDiagonal==1);

    otherwise
        warning('backtrace','on');
        warning('The modeString input: %s is not yet defined. Throwing error.',modeString);
        error('Undefined modeString input');
        
end % Ends looping through edges


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

%% Grab a colormap for plotting options
if flag_do_plots || flag_do_debug
    figure(383838)
    colorMapMatrixOrString = colormap('turbo');
    close(383838);
    greenToRedColormap = colorMapMatrixOrString(100:end,:);
    Ncolors = 32;
    reducedGreenToRedColorMap = fcn_plotRoad_reduceColorMap(greenToRedColormap, Ncolors, -1);
    % reducedRedToGreenColorMap = flipud(reducedGreenToRedColorMap);
    %%%% Uncomment the following two lines to see the colormap
    % colormap(reducedRedToGreenColorMap);
    % colorbar;
end

if flag_do_plots
    addNudge = 0.1;

    % check whether the figure already has data
    temp_h = figure(figNum); %#ok<NASGU>
    flag_rescale_axis = 0;
    if isempty(get(gca,'UserData'))
        flag_rescale_axis = 1; % Set to 1 to force rescaling
        plotFlags = struct;
        plotFlags.flagAlreadyPlotted = 1;
        set(gca,'UserData',plotFlags)
    end

    % Fill the polytopes
    polytopeIDs = unique(pointsWithData(:,4));
    polytopeIDs = polytopeIDs(polytopeIDs>0);
    clear polytopes
    Npolytopes = length(polytopeIDs);
    polytopes(Npolytopes) = struct;
    for ith_polytope = 1:Npolytopes
        thisPolytope = polytopeIDs(ith_polytope);
        thisPolytopeVertexIndices = pointsWithData(:,4)==thisPolytope;
        thisPolytopeVertices = pointsWithData(thisPolytopeVertexIndices,1:2);
        polytopes(ith_polytope).vertices = thisPolytopeVertices;
        polytopes(ith_polytope).cost = 0.4;
    end
    % polytopes = fcn_MapGen_polytopesFillFieldsFromVertices(polytopes);

    % Plot the polytopes
    fcn_INTERNAL_plotPolytopes(polytopes, figNum)

    % Plot the visibiliity graph for all from and to lines
    fcn_VGraph_plotVGraph(vGraph, pointsWithData, 'g-');

    % Plot the start and end points
    plot(startXY(1),startXY(2),'.','Color',[0 0.5 0],'MarkerSize',20);
    plot(finishXY(1),finishXY(2),'r.','MarkerSize',20);
    text(startXY(:,1),startXY(:,2)+addNudge,'Start');
    text(finishXY(:,1),finishXY(:,2)+addNudge,'Finish');

    % label point ids for debugging. The last two points are start and
    % finish, so do not need to be plotted and labeled.
    plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
    text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));


    % Grab all the edges processed so far
    [edgeFrom, edgeTo] = find(vGraphNoDiagonal==1);
    Nedges = length(edgeFrom);

    % Set up the plotting so that it goes only from midway to finish. This
    % is because each edge can go both ways - from/to and to/from. If the
    % plot shows the entire edge, one of the edges is always covered.
    dataToPlot = [];
    for ith_edge = 1:Nedges
        fromIndex = edgeFrom(ith_edge);
        toIndex = edgeTo(ith_edge);
        thisCost = cGraph(fromIndex, toIndex);
        midpoint = (pointsWithData(fromIndex,1:2) + pointsWithData(toIndex,1:2))/2;
        edgeToPlot = [midpoint; pointsWithData(toIndex,1:2); nan(1,2)];
        dataToPlot = [...
            dataToPlot; ...
            [edgeToPlot thisCost*ones(3,1)]]; %#ok<AGROW>
    end

    costs = dataToPlot(:,3);
    costsNotInf = costs(~isinf(costs));
    maxPlotData = max(costsNotInf);
    normalizedDataToPlot = dataToPlot;
    normalizedDataToPlot(:,3) = normalizedDataToPlot(:,3)./maxPlotData;

    clear plotFormat
    plotFormat.LineStyle = '-';
    plotFormat.LineWidth = 5;
    plotFormat.Marker = '.';
    plotFormat.MarkerSize = 10;

    colormap(gca,reducedGreenToRedColorMap);
    fcn_plotRoad_plotXYI([normalizedDataToPlot(:,1) normalizedDataToPlot(:,2) normalizedDataToPlot(:,3)], (plotFormat), (reducedGreenToRedColorMap), (figNum));

    h_colorbar = colorbar;
    Nticks = length(h_colorbar.Ticks);
    h_colorbar.Ticks = linspace(0, 1, Nticks) ; %Create ticks from zero to 1
    colorbarValues   = round(linspace(0, maxPlotData, Nticks),2);
    h_colorbar.TickLabels = num2cell(colorbarValues) ;    % Replace the labels of ticks with numbers
    % h_colorbar.TickLabels{end} = 'inf'; % Top number is reserved for infinity
    h_colorbar.Label.String = 'Cost (normalized)';

    title('');

    % Plot the start and end points
    plot(startXY(1),startXY(2),'.','Color',[0 0.5 0],'MarkerSize',20);
    plot(finishXY(1),finishXY(2),'r.','MarkerSize',20);
    text(startXY(:,1),startXY(:,2)+addNudge,'Start');
    text(finishXY(:,1),finishXY(:,2)+addNudge,'Finish');

    % label point ids for debugging. The last two points are start and
    % finish, so do not need to be plotted and labeled.
    plot(pointsWithData(1:end-2,1), pointsWithData(1:end-2,2),'LineStyle','none','Marker','o','MarkerFaceColor',[255,165,0]./255);
    text(pointsWithData(1:end-2,1)+addNudge,pointsWithData(1:end-2,2)+addNudge,string(pointsWithData(1:end-2,3)));

    % Set the axis
    if 1==flag_rescale_axis
        set(gca,'XLimitMethod','padded')
        set(gca,'YLimitMethod','padded')
        temp = axis;
        axis([temp(1,1)-1 temp(1,2)+1 temp(1,3)-1 temp(1,4)+1]);
    end


end % Ends check if plotting

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function

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
