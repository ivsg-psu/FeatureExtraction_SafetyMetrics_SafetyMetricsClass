function laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPaths, varargin)
%% fcn_SafetyMetrics_checkTrajLaneMarkerCollison
% 
% Given a trajectory (points) and lane marker polylines (NaN-separated),
% this function finds intersections.
% 
% FORMAT:
% 
% laneCollisionStruct = fcn_SafetyMetrics_checkTrajLaneMarkerCollison(vehicleTrajectoryPath, laneMarkerPath, (figNum))
% 
% INPUTS:
% 
%       vehicleTrajectoryPath: N x 2 [X Y] - The trajectory of a vehicle
% 
%       laneMarkerPaths: M x 2 [X Y], NaN rows separate different lane
%       markers
% 
%      (OPTIONAL INPUTS)
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%    
%
% OUTPUTS:
% 
%   laneCollisionStruct: struct array (one per lane marker) with fields:
%       .lane_marker_pathXY: (Lane marker path)
% 
%       .did_intersect: (Check for an intersection)
% 
%       .intersections_pathXY: (intersection points on lane marker)
% 
%       .intersection_traj_vector_index: (Index of the trajectory point 
%                              that is intersected with the lane marker)
% 
% DEPENDENCIES:
% 
%     fcn_DebugTools_checkInputsToFunctions
%     fcn_Path_findProjectionHitOntoPath
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_SafetyMetrics_checkTrajLaneMarkerCollison.m 
%
%       for a full test suite.
% 
% This function was written on 2026_02_15 by Aneesh Batchu
% Questions or comments? contact abb6486@psu.edu or sbrennan@psu.edu

% 
% REVISION HISTORY:
% 
% 2026_02_15 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally
% 
% 2026_02_23 by Aneesh Batchu, abb6486@psu.edu
% In fcn_SafetyMetrics_checkTrajLaneMarkerCollison
%   % * Modified "fcn_INTERNAL_generateLaneMarkerCell" to store one
%   %   % point lane markers as a seperate lane marker. 

% TO DO:
% 
% - fill in to-do items here.

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 3; % The largest Number of argument inputs to the function
flag_max_speed = 0;
if (nargin==MAX_NARGIN && isequal(varargin{end},-1))
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 0; % Flag to perform input checking
    flag_max_speed = 1;
else
    % Check to see if we are externally setting debug mode to be "on"
    flag_do_debug = 0; %     % Flag to plot the results for debugging
    flag_check_inputs = 1; % Flag to perform input checking
    MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_CHECK_INPUTS");
    MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG_OSM2SHP_FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG_OSM2SHP_FLAG_CHECK_INPUTS);
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

if 0 == flag_max_speed
    if flag_check_inputs == 1
        % Are there the right number of inputs?
        narginchk(2,MAX_NARGIN);

		% Validate the vehicleTrajectoryPath input is a 2 or 4 column
        % matrix and can contain NaN values
		fcn_DebugTools_checkInputsToFunctions(vehicleTrajectoryPath, '2or4column_of_mixed');

        % Validate the laneMarkerPaths input is a 2 column matrix and can 
        % contain NaN values
		fcn_DebugTools_checkInputsToFunctions(laneMarkerPaths, '2column_of_mixed');

    end
end

% Check to see if user specifies figNum?
flag_do_plots = 0; % Default is to NOT show plots
if (0==flag_max_speed) && (MAX_NARGIN == nargin) 
    temp = varargin{end};
    if ~isempty(temp)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get XY coordinates (EN) of vehicle trajectory
trajectoryXY = vehicleTrajectoryPath(:,1:2);

% Get XY coordinates (EN) of lane marker coordinates
laneMarkersXY = laneMarkerPaths(:,1:2);

% Split the lane markers in the matrix seperated by NaNs and append them to
% a cell array
laneMarkerXY_cell = fcn_INTERNAL_generateLaneMarkerCell(laneMarkersXY);

% Preallocate output struct
laneCollisionStruct = repmat(struct( ...
    'lane_marker_pathXY', [], ...
    'did_intersect', false, ...
    'intersections_pathXY', [], ...
    'intersection_traj_vector_index', []), ...
    length(laneMarkerXY_cell), 1);

% Loop over each lane marker path
for ith_lane = 1:length(laneMarkerXY_cell(:,1))

    % Grab a cell of the lane marker
    laneMarker_pathXY = laneMarkerXY_cell{ith_lane, 1};

    % Skip degenerate lane markers
    if size(laneMarker_pathXY,1) < 2
        laneCollisionStruct(ith_lane).lane_marker_pathXY = laneMarker_pathXY;
        continue;
    end

   % ----------- DECLARE VARIABLES TO FIND ALL INTERSECTIONS -------------

    % Number of points in the trajectory
    N_trajPoints = length(trajectoryXY(:,1));
    
    % Initialize the matrix of intersection points of lane marker path
    all_hits_laneMarker = [];

    % Initialize the matrix of intersection points of lane marker path
    all_trajIndices_of_hits = [];

    % Returns all the intersections (no projections)
    flag_search_type = 2;

    % ------------------- FIND ALL INTERSECTIONS ----------------------

    for ith_vector = 1:N_trajPoints-1
        % Start vector of a segement of a trajectory
        start_vector = trajectoryXY(ith_vector,:);
        end_vector   = trajectoryXY(ith_vector+1,:);

        % locations is Mx2 if multiple hits
        [~, locations, ~, ~, ~] = fcn_Path_findProjectionHitOntoPath( ...
            laneMarker_pathXY, start_vector, end_vector, flag_search_type, (-1));

        if all(~isnan(locations(:)))

            % Append the intersection points of lane marker
            all_hits_laneMarker = [all_hits_laneMarker; locations]; %#ok<AGROW>

            % If same vector intersects with the lane marker path N times,
            % the index will be repeated N times. For example, 17th vector
            % hits the lane marker at locations [1, 0; 2, 0; 3, 0]. The
            all_trajIndices_of_hits = [all_trajIndices_of_hits; repmat(ith_vector, size(locations,1), 1)]; %#ok<AGROW>
        end
    end


    % Populate Results

    % Intersection related
    laneCollisionStruct(ith_lane).lane_marker_pathXY = laneMarker_pathXY;
    laneCollisionStruct(ith_lane).did_intersect = ~isempty(all_hits_laneMarker);
    laneCollisionStruct(ith_lane).intersections_pathXY = all_hits_laneMarker;
    laneCollisionStruct(ith_lane).intersection_traj_vector_index = all_trajIndices_of_hits;


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

    temp_h = figure(figNum);
    flag_rescale_axis = 0;
    if isempty(get(temp_h,'Children'))
        flag_rescale_axis = 1;
    end

    figure(figNum);

    hold on;
    grid on;
    axis equal;

    % Plot the trajectory once
    hTraj = plot(trajectoryXY(:,1), trajectoryXY(:,2), 'k.-', 'MarkerSize', 15, 'LineWidth', 2);
    hTraj.DisplayName = 'Trajectory';

    for ith_lane = 1:length(laneCollisionStruct)

        path = laneCollisionStruct(ith_lane).lane_marker_pathXY;

        % Plot lane marker
        hPath = plot(path(:,1), path(:,2), 'r.-', 'LineWidth', 3, 'MarkerSize', 15);
        if ith_lane == 1
            hPath.DisplayName = 'Lane marker';
        else
            hPath.HandleVisibility = 'off';
        end

        % Plot hits (if any)
        hits = laneCollisionStruct(ith_lane).intersections_pathXY;
        % hitSegIdx = laneCollisionStruct(ith_lane).intersection_traj_vector_index;

        if ~isempty(hits)

            hHits = plot(hits(:,1), hits(:,2), 'bo', 'MarkerSize', 12, 'LineWidth', 2);

            if ith_lane == 1
                hHits.DisplayName = 'Intersections';
            else
                hHits.HandleVisibility = 'off';
            end

            % % Annotate each hit with its traj vector index
            % for ith_hit = 1:size(hits,1)
            %     text(hits(ith_hit,1), hits(ith_hit,2), ...
            %         sprintf('seg %d', hitSegIdx(ith_hit)), ...
            %         'Color', [0 0 1], 'FontSize', 10);
            % end
        end

    end
    
    % Legend ON
    legend('show','Location','best');

    % Make axis slightly larger?
    if flag_rescale_axis
        temp = axis;
        axis_range_x = temp(2)-temp(1);
        axis_range_y = temp(4)-temp(3);
        percent_larger = 0.1;
        axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);
    end

end

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

% Check debugTools later - It might have a faster algo
function laneMarkerXY_cell = fcn_INTERNAL_generateLaneMarkerCell(laneMarkersXY)

search_NaNs = any(isnan(laneMarkersXY),2);
nan_indices = find(search_NaNs); 

start_index = 1;
laneMarkerXY_cell = {};

for ith_laneMarker = 1:length(nan_indices)
    stop_index = nan_indices(ith_laneMarker) - 1; 

    if stop_index >= start_index
        laneMarkerSegment = laneMarkersXY(start_index:stop_index, :); 
        % laneMarkerSegment = laneMarkerSegment(~any(isnan(laneMarkerSegment),2),:);
        if ~isempty(laneMarkerSegment)
            laneMarkerXY_cell{end+1,1} = laneMarkerSegment; %#ok<AGROW>
        end
        start_index = nan_indices(ith_laneMarker) + 1; 
    end
end

% If [NaN, NaN] is not added to the laneMarkersXY matrix. This section of
% the code grabs the last chunk 
if start_index <= size(laneMarkersXY,1)
    laneMarkerSegment = laneMarkersXY(start_index:end,:);

    if ~isempty(laneMarkerSegment)
        laneMarkerXY_cell{end+1,1} = laneMarkerSegment;
    end
end

end


