function laneDistanceStruct = fcn_SafetyMetrics_computeTrajLaneDistance(vehicleTrajectoryPath, laneMarkerPaths, varargin)
%% fcn_SafetyMetrics_computeTrajLaneDistance
% 
% Given a trajectory (points) and lane marker polylines (NaN-separated),
% this function computes distance-to-lane over the trajectory 
% 
% FORMAT:
% 
% laneDistanceStruct = fcn_SafetyMetrics_computeTrajLaneDistance(vehicleTrajectoryPath, laneMarkerPath, (figNum))
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
%   laneDistanceStruct: struct array (one per lane marker) with fields:
%       .lane_marker_pathXY: (Lane marker path)
% 
%       .closest_points_on_pathXY_to_traj: (Closest points on lane marker 
%                                           to the each trajectory point)
% 
%       .distance_profile: (The distance from the closest points on lane
%                           marker to the trajectory points)
% 
%       .min_dist_btw_traj_and_path: (Minimum distance of the distance
%                                     profile)
% 
%       .min_distance_traj_index: (The index of trajectory point closest to 
%                                  lane marker) 
% 
%       .closest_point_pathXY_at_min: (Closest point of the lane marker to
%                                       trajectory)
% 
% DEPENDENCIES:
% 
%     fcn_DebugTools_checkInputsToFunctions
%     fcn_Path_snapPointOntoNearestPath
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_SafetyMetrics_computeTrajLaneDistance.m 
%
%       for a full test suite.
% 
% This function was written on 2026_02_15 by Aneesh Batchu
% Questions or comments? contact abb6486@psu.edu or sbrennan@psu.edu

% 
% REVISION HISTORY:
% 
% 2026_02_10 by Aneesh Batchu, abb6486@psu.edu
% - wrote the code originally
% 
% 2026_02_15 by Aneesh Batchu, abb6486@psu.edu
% - Separated this function from
% "fcn_SafetyMetrics_checkTrajLaneMarkerCollison"
%
% 2026_02_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_SafetyMetrics_computeTrajLaneDistance
%   % * Replaced OSM+2SHP flags with SAFETYMETRICS
% 
% 2026_02_23 by Aneesh Batchu, abb6486@psu.edu
% In fcn_SafetyMetrics_computeTrajLaneDistance
%   % * Modified "fcn_INTERNAL_generateLaneMarkerCell" to store one
%   %   % point lane markers as a seperate lane marker. 
%   % * Modified debug optiond to skip plotting if there are no
%   %   % closest_path_points_plotting for plotting

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
    MATLABFLAG__FLAG_CHECK_INPUTS = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_CHECK_INPUTS");
    MATLABFLAG__FLAG_DO_DEBUG = getenv("MATLABFLAG_SAFETYMETRICS_FLAG_DO_DEBUG");
    if ~isempty(MATLABFLAG__FLAG_CHECK_INPUTS) && ~isempty(MATLABFLAG__FLAG_DO_DEBUG)
        flag_do_debug = str2double(MATLABFLAG__FLAG_DO_DEBUG); 
        flag_check_inputs  = str2double(MATLABFLAG__FLAG_CHECK_INPUTS);
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
laneDistanceStruct = repmat(struct( ...
    'lane_marker_pathXY', [], ...
    'closest_points_on_pathXY_to_traj', [],...
    'distance_profile', [], ...
    'min_dist_btw_traj_and_path', [], ...
    'min_distance_traj_index', [], ...
    'closest_point_pathXY_at_min', []), ...
    length(laneMarkerXY_cell), 1);

% Number of points in the trajectory
N_trajPoints = length(trajectoryXY(:,1));

% Loop over each lane marker path
for ith_lane = 1:length(laneMarkerXY_cell(:,1))

    % Grab a cell of the lane marker
    laneMarker_pathXY = laneMarkerXY_cell{ith_lane, 1};

    % Skip degenerate lane markers
    if size(laneMarker_pathXY,1) < 2
        laneDistanceStruct(ith_lane).lane_marker_pathXY = laneMarker_pathXY;
        continue;
    end
    
    % -------- DECLARE VARIABLES TO CALCULATE THE DISTANCE PROFILE --------

    % Pre-allocate the closest_point matrix
    closest_path_points = nan(N_trajPoints,2);


    % Loop over all trajectory points
    for ith_trajPoint = 1:N_trajPoints

        % --------------- CALCULATE THE DISTANCE PROFILE ------------------

        % Select a single trajectory point
        trajPointXY = trajectoryXY(ith_trajPoint,:);

        % Find the closest point on lane marker path from the trajectory point
        [closest_path_point, ~, ~, ~, ~] = ...
            fcn_Path_snapPointOntoNearestPath(trajPointXY, laneMarker_pathXY, (-1));

        % Closest path points
        closest_path_points(ith_trajPoint,:) = closest_path_point;

    end


    % Distance between the trajectory points and closest lane marker path points
    distance_btw_traj_to_laneMarkerPath = ((trajectoryXY(:,1) - closest_path_points(:,1)).^2 +...
        (trajectoryXY(:,2) - closest_path_points(:,2)).^2).^0.5;
    
    % Round the distances to the 6th decimal 
    distance_btw_traj_to_laneMarkerPath = round(distance_btw_traj_to_laneMarkerPath, 6);

    % Find the minimum distance from traj to lane marker path
    [min_distance, ~] = min(distance_btw_traj_to_laneMarkerPath);

    % Find all indices of trajectory whose distance from traj to lane
    % marker path is measured min_distance
    min_indices = find(min_distance == distance_btw_traj_to_laneMarkerPath); 


    % Populate Results

    % Distance related
    laneDistanceStruct(ith_lane).lane_marker_pathXY = laneMarker_pathXY;
    laneDistanceStruct(ith_lane).closest_points_on_pathXY_to_traj = closest_path_points;
    laneDistanceStruct(ith_lane).distance_profile = distance_btw_traj_to_laneMarkerPath;
    laneDistanceStruct(ith_lane).min_dist_btw_traj_and_path = min_distance;
    laneDistanceStruct(ith_lane).min_distance_traj_index = min_indices;
    laneDistanceStruct(ith_lane).closest_point_pathXY_at_min = closest_path_points(min_indices,:);

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

    for ith_resultCell = 1:length(laneDistanceStruct)

        % Lane marker path
        path = laneDistanceStruct(ith_resultCell).lane_marker_pathXY;

        % Trajectory of a vehicle
        trajectory = trajectoryXY;

        % Closest points of lane marker path to trajectory
        closest_path_points_plotting = laneDistanceStruct(ith_resultCell).closest_points_on_pathXY_to_traj;

        if isempty(closest_path_points_plotting)
            % ith_resultCell
            continue
        end

        % This is to plot quiver (arrow)
        dx = closest_path_points_plotting(:,1) - trajectory(:,1);
        dy = closest_path_points_plotting(:,2) - trajectory(:,2);

        % Plot the path
        hPath = plot(path(:,1),path(:,2),'r.-','Linewidth',3,'Markersize',20);

        % Plot the query point
        hTraj = plot(trajectory(:,1),trajectory(:,2),'k.-','MarkerSize',20);

        % Plot the closest points on the lane marker path from trajectory
        hClosest = plot(closest_path_points_plotting(:,1),closest_path_points_plotting(:,2),'b.','MarkerSize',15);

        % Plot a quiver (an arrow)
        hArrow = quiver(trajectory(:,1), trajectory(:,2), dx, dy, 0, 'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);

        % Show legend only once
        if ith_resultCell == 1
            hPath.DisplayName    = 'Path';
            hTraj.DisplayName    = 'Trajectory';
            hClosest.DisplayName = 'Closest Path Point';
            hArrow.HandleVisibility = 'off';
        else
            hPath.HandleVisibility    = 'off';
            hTraj.HandleVisibility    = 'off';
            hClosest.HandleVisibility = 'off';
            hArrow.HandleVisibility   = 'off';
        end

    end

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

    % Finds the last index of a lane marker
    stop_index = nan_indices(ith_laneMarker) - 1; 

    if stop_index >= start_index

        % Grabs the lane marker based on calculated start and stop index
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


