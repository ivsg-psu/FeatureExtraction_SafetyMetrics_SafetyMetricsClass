function [TLC_lane1_time,TLC_lane2_time] = fcn_SafetyMetrics_calcTimeToLaneCollision(unitVectors_vehicleTraj, vehicleTraj, rearAxle, lanePatches, varargin)
%% fcn_SafetyMetrics_TimeToLaneCollision
% 
% This function computes time-to-lane-crossing (TLC) signals by casting a
% ray forward from the vehicle at each trajectory sample and computing when
% that ray intersects lane boundary surfaces represented as triangulated
% patch objects (lane_patches).
%
% FORMAT:
%
% [TLC_lane1_time,TLC_lane2_time] = fcn_SafetyMetrics_TimeToLaneCollision(u, trajectory, rear_axle, lane_patches, (figNum))
%
% INPUTS:
%
%     unitVectors_vehicleTraj: a matrix with the unit vectors of the
%     vehicle trajectory. [time,x,y]
% 
%     vehicleTraj: [time,x,y,yaw_angle] 4x1 vector
% 
%     rearAxle: a matrix containing the points of where the center of the
%     rear axle is. [x,y]
% 
%     lanePatches : 1xN struct contaning data for lanes: Vertices, Faces,
%     FaceVertexCData, FaceColor, EdgeColor, LineWidth, FaceAlpha
% 
%      (OPTIONAL INPUTS)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed.
%
% OUTPUTS:
%
%  TLC_lane1_time: 1xn matrix of the time to lane crossing for a specfic lane.
%  TLC_lane2_time: 1xn matrix of the time to lane crossing for a specfic lane.
%
%
% DEPENDENCIES:
%
% TriangleRayIntersection.m
%
%
% This function was written on 2023_08_10 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_08_10 by Marcus Putz
% - first write of function
%
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_TimeToLaneCollision
%   % * Renamed "fcn_SafetyMetrics_TLC" to fcn_SafetyMetrics_TimeToLaneCollision
%   % * Added DebugTools to check the inputs
%   % * Updated the function and variable names to match the latest format

% TO-DO:
%
% 2026_02_18 by Aneesh Batchu, abb6486@psu.edu
% - In fcn_SafetyMetrics_TimeToLaneCollision
%   % * Remove hard-coded “two lanes only” assumption
%   %   % * Right now outputs are fixed: TLC_lane1_time, TLC_lane2_time.
%   %   % * Upgrade to:
%   %   %   % * TLC_time as N x numLanes matrix, or
%   %   %   % * TLC_time_byLane as cell array.%   % * Need a test script
%   % * Move the 3D plot (figure(485)) to the debug section
%   % * Eliminate hard-coded scenario gating like vehicleTraj(i,3) > 1.9
%   %   % * That is “default data being analyzed” (a scenario-specific threshold).
%   %   % * Replace with a geometric rule:
%   %   %   % * pick the nearest lane boundary intersection in front of the
%   %   %   %   % vehicle, or select lane surfaces based on lane IDs, 
%   %   %   %   % side (left/right), or distance sign.
%   % * Replace invalid checks xcoor_lane1{1,1}(i,1) ~= 0
%   %   % * Code stores [NaN NaN NaN] for no hit — so you should check:
%   %   %   % * ~isnan(xcoor_lane1{k}(i,3))
%   %   %   % * Checking ~=0 can falsely reject a valid intersection at x=0.
%   % * Preallocate TLC outputs with NaN
%   % * Move all figure to debug section
%   % * Use correct ray origin points
%   %   % * Right now you use rear_axle2. For generality, allow choosing ray origin:
%   %   % *rear axle / CG / front axle / polygon vertices 
%   %   %   % across vehicle footprint.
%   % * Return richer outputs (not just TLC_time)
%   %   % * Return struct with:
%   %   %   % * TLC_time (N×1, NaN if no hit)
%   %   %   % * did_intersect flags (N×1 logical)
%   %   %   % * intersection_points (N×2, NaN row if no hit)
%   %   %   % * intersection_time (N×1)
%   %   %   % * event indices (indices of key events; e.g., hit exists, TTC<threshold)
%   %   %   % * event timestamps (timestamps: (time column) vehicleTraj(event_indices,1))
%   % * Need a test script

%% Debugging and Input checks

% Check if flag_max_speed set. This occurs if the figNum variable input
% argument (varargin) is given a number of -1, which is not a valid figure
% number.
MAX_NARGIN = 5; % The largest Number of argument inputs to the function
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
        narginchk(4,MAX_NARGIN);

        % unitVectors_vehicleTraj should have 3 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            unitVectors_vehicleTraj, '3column_of_numbers');


        % vehicleTraj should have 4 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            vehicleTraj, '4column_of_numbers');


        % rearAxle should have 2 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            rearAxle, '2column_of_numbers');
        

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


%% Start of main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%See: http://patorjk.com/software/taag/#p=display&f=Big&t=Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(unitVectors_vehicleTraj)
    dir = [unitVectors_vehicleTraj(i,2),unitVectors_vehicleTraj(i,3),unitVectors_vehicleTraj(i,1)];
    pos = [rearAxle(i,1),rearAxle(i,2),vehicleTraj(i,1)];
    
    for i_1  = 1:length(lanePatches)
        vert1_lane = lanePatches(i_1).Vertices(lanePatches(i_1).Faces(:,1),:);
        vert2_lane = lanePatches(i_1).Vertices(lanePatches(i_1).Faces(:,2),:);
        vert3_lane = lanePatches(i_1).Vertices(lanePatches(i_1).Faces(:,3),:);
        
        
        [~, ~, ~, ~, xcoor_lane] = TriangleRayIntersection(pos,dir, vert1_lane, vert2_lane, vert3_lane,'planeType','one sided');
        xcoor_lane = rmmissing(xcoor_lane);
        % If there is data in the Xcoor_lane save it, if not save NaN.
        if isempty(xcoor_lane) == 0
            xcoor_lane1{i_1,:}(i,:) = xcoor_lane;
            %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
        else
            xcoor_lane1{i_1,1}(i,:) = [NaN,NaN,NaN];
        end
    end
end
% Plotting the TLC rays and calculating it. 
flag_plot_lane_intersect = 1;
if flag_plot_lane_intersect == 1
    for i = 1:length(unitVectors_vehicleTraj)
        figure(495)
        % The following if statments make sure to only use the rays that
        % make sense for each lane. (The 'TriangleRayIntersection' shoots
        % rays off and will continue returning intersections for all lanes
        % even if the lane is on the other side of another lane.)
        if xcoor_lane1{1,1}(i,1) ~= 0 && vehicleTraj(i,3) > 1.9
            plot3([vehicleTraj(i,2) xcoor_lane1{1,1}(i,1)],[vehicleTraj(i,3) xcoor_lane1{1,1}(i,2)],[vehicleTraj(i,1) xcoor_lane1{1,1}(i,3)],'b')
            hold on
            TLC_lane2_time(i) = xcoor_lane1{1,1}(i,3) - vehicleTraj(i,1); 
        end
        if xcoor_lane1{2,1}(i,1) ~= 0
            plot3([vehicleTraj(i,2) xcoor_lane1{2,1}(i,1)],[vehicleTraj(i,3) xcoor_lane1{2,1}(i,2)],[vehicleTraj(i,1) xcoor_lane1{2,1}(i,3)],'g')
            hold on
            TLC_lane1_time(i) = xcoor_lane1{2,1}(i,3) - vehicleTraj(i,1); 
        end
    end
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

    % temp_h = figure(fig_num);
    % flag_rescale_axis = 0;
    % if isempty(get(temp_h,'Children'))
    %     flag_rescale_axis = 1;
    % end

    % Plot the TLC vs time.
    figure(figNum)
    plot(TLC_lane1_time)
    title('TLC of the middle lane');
    grid on
    xlabel('Time');
    ylabel('TLC');

    figure(936)
    plot(TLC_lane2_time)
    title('TLC of the outside lane');
    grid on
    xlabel('Time');
    ylabel('TLC');



    % % Make axis slightly larger?
    % if flag_rescale_axis
    %     temp = axis;
    %     axis_range_x = temp(2)-temp(1);
    %     axis_range_y = temp(4)-temp(3);
    %     percent_larger = 0.1;
    %     axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);
    % end


end % Ends the flag_do_plot if statement

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end


end % Ends the function

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

