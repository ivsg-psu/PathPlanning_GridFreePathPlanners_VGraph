function unique_deduped_points_struct = fcn_VGraph_convertPolytopetoDedupedPoints(pointsWithData, varargin)
% this function takes in the table of all points, which in a fully tiled
% field contains repeated points when a vertex belongs to multiple
% polytopes, and returns a points data structure without duplicates, where
% each point has an associated list of polytopes to which it belongs
%
% FORMAT:
%
% unique_deduped_points_struct = fcn_BoundedAStar_convertPolytopetoDedupedPoints(pointsWithData, (figNum))
%
% INPUTS:
%     pointsWithData: p-by-5 matrix of all the possible origination points for
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
% (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
% unique_deduped_points_struct: an L-dimensional struct where L is the
% number of unique points in
%   the field with fields .x and .y for the x and y coordintes of the
%   point, respectively and .polys containing a list of all the polytope
%   ids this point is a vertex of
%
% Examples:
%      see script_test_fcn_BoundedAStar_convertPolytopetoDedupedPoints
%
% This function was written on in 2022 by Stephen Harnett
% Questions or comments? sjharnett@psu.edu

% REVISION HISTORY:
% 
% As: fcn_convert_polytope_struct_to_deduped_points
% 2022_05_01 - S. Harnett
% - first write of code
%
% As: fcn_BoundedAStar_convertPolytopetoDedupedPoints
% 
% 2025_07_17 - K. Hayes, kxh1031@psu.edu
% - copied function from fcn_convert_polytope_struct_to_deduped_points.m
%    to follow library conventions
% 
% 2025_08_11 - K. Hayes
% - updated fcn header and formatting
% - added input checking
%
% As: fcn_Visibility_convertPolytopetoDedupedPoints
% 
% 2025_11_07 by Sean Brennan, sbrennan@psu.edu
% - Changed global flags from _MAPGEN_ to _VGRAPH_
% - Changed all+_pts to pointsWithData
%
% As: fcn_VGraph_convertPolytopetoDedupedPoints
% 
% 2025_11_07 by Sean Brennan, sbrennan@psu.edu
% - Renamed fcn_Visibility_convertPolytopetoDedupedPoints to fcn_VGraph_convertPolytopetoDedupedPoints
% - Cleared extra figure command out of Inputs section
%
% 2025_11_17 by Sean Brennan, sbrennan@psu.edu
% - Updated formatting to Markdown on Rev history
% - Added figNum documentation to header docstrings
% - Cleaned up variable naming in all functions
%   % fig+_num to figNum

% TO-DO:
% 2025_11_21 by Sean Brennan, sbrennan@psu.edu
% - (add items here)


%% Debugging and Input checks
% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 2; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %     % Flag to plot the results for debugging
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
else
    debug_figNum = []; %#ok<NASGU>
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

if 0==flag_max_speed
    if flag_check_inputs
        % Are there the right number of inputs?
        narginchk(1,MAX_NARGIN);

        % Check the pointsWithData input, make sure it has 5 columns
        fcn_DebugTools_checkInputsToFunctions(...
            pointsWithData, '5column_of_numbers');
    end
end


% Does user want to show the plots?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin)
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        figNum = temp;
        flag_do_plots = 1;
    end
end


%% Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%See: http://patorjk.com/software/taag/#p=display&f=Big&t=Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§


deduped_points_struct = [];
for i = 1:size(pointsWithData,1)
    deduped_points_struct(i).x = pointsWithData(i,1);
    deduped_points_struct(i).y = pointsWithData(i,2);
    same_x_idx = find(round(pointsWithData(:,1),5)==round(pointsWithData(i,1),5));
    same_y_idx = find(round(pointsWithData(:,2),5)==round(pointsWithData(i,2),5));
    
    % find ids that have both same x and y
    same_point_idx = intersect(same_x_idx,same_y_idx);

    % make a list of obstacles with the same point
    % find indecies of rows for same_point_idx and column 4
    idx = sub2ind(size(pointsWithData), same_point_idx, 4.*ones(size(same_point_idx,1),size(same_point_idx,2)));
    % go to these ids and store in obstalce list
    obs_on_cur_pt = pointsWithData(idx);
    deduped_points_struct(i).polys = obs_on_cur_pt;
end
x_y_pairs = [round(extractfield(deduped_points_struct,'x'),5);round(extractfield(deduped_points_struct,'y'),5)]';
[C,unique_pair_idxs,ic] = unique(x_y_pairs,'rows');
unique_pairs = x_y_pairs(unique_pair_idxs,:);
unique_deduped_points_struct = deduped_points_struct(unique_pair_idxs);

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

end


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