function polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, varargin)
% fcn_VGraph_helperFillPolytopesFromPointData
% helper function that fills in 2D polytpes given point data including XY
% position, polytope membership, etc.
%
% FORMAT:
%
%     polytopes = fcn_VGraph_helperFillPolytopesFromPointData(pointsWithData, varargin)
%
% INPUTS:
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
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      polytopes: an individual structure or structure array of 'polytopes'
%      type that stores the polytopes to be filled. See
%      fcn_MapGen_polytopeFillEmptyPoly for structure details.
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_MapGen_plotPolytopes
%
% EXAMPLES:
%
% See the script: script_test_fcn_VGraph_helperFillPolytopesFromPointData
% for a full test suite.
%
% This function was written on 2025_11_18 by Sean Brennan
% Questions or comments? contact sbrennan@psu.edu

% REVISION HISTORY:
% As: fcn_VGraph_helperFillPolytopesFromPointDat
% 
% 2025_11_18 - S. Brennan
% - First write of function using fcn_VGraph_co+stCalculate as template


% TO DO:
% - fill in to-do items here.


%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 2; % The largest Number of argument inputs to the function
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
        narginchk(1,MAX_NARGIN);

        % Check the pointsWithData input. It should have 5 columns,
        % 3+ rows
        fcn_DebugTools_checkInputsToFunctions(pointsWithData, '5column_of_numbers', [3 4]);

    end
end


% % Does user want to specify modeString?
% % initialize default values
% modeString = 'distance from finish';
% if 3 <= nargin
%     temp = varargin{1};
%     if ~isempty(temp)
%         modeString = temp;
%     end
% end

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
% Fill the polytopes
polytopeIDs = unique(pointsWithData(:,4));
polytopeIDs = polytopeIDs(polytopeIDs>0);

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
    % addNudge = 0.1;

    % check whether the figure already has data
    temp_h = figure(figNum); %#ok<NASGU>
    flag_rescale_axis = 0;
    if isempty(get(gca,'UserData'))
        flag_rescale_axis = 1; % Set to 1 to force rescaling
        plotFlags = struct;
        plotFlags.flagAlreadyPlotted = 1;
        set(gca,'UserData',plotFlags)
    end

    % Plot the polytopes
    fcn_INTERNAL_plotPolytopes(polytopes, figNum)

    % Set the axis
    if 1==flag_rescale_axis
        drawnow;
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
