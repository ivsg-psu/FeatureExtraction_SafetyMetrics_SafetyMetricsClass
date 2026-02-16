function [time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
    fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, varargin)
% fcn_SafetyMetrics_showVehicleTrajandMetricInputs
% This code will ... (???)
% 
% FORMAT:
% 
% time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
%     fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, (object), (figNum))
% 
% INPUTS:
% 
%   time: time taken by the vehicle to complete the trajectory
%   vehicleTraj: x,y coordinates of the vehicle trajectory
%   metricInputs: x,y coordinates of the metric inputs object: object
%
%      (OPTIONAL INPUTS)
%
%      object: object = 1, if an object is in the trajectory, 0 otherwise
%
%      figNum: a figure number to plot results. If set to -1, skips any
%      input checking or debugging, no figures will be generated, and sets
%      up code to maximize speed.
%
% OUTPUTS:
%
%      time: matrix of time
%
%      x_vehicleTraj:x coordinates of vehicle trajectory
%
%      y_vehicleTraj:y coordinates of vehicle trajectory
%
%      yaw: matrix of yaw angles for each xy point of the vehicle trajectory
%
%      laneBoundaries: cooridantes of the laneBoundaries
%
%      centerLines: x and y coordinates of the centerlines
%
%      flag_object: a boolean value of if to plot an object. 1 = plot object
%
% DEPENDENCIES:
% 
%     fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_SafetyMetrics_showVehicleTrajandMetricInputs 
%
%       for a full test suite.
% 
% This function was written on 2023_05_17 by Marcus Putz and Sean Brennan
% Questions or comments? contact sbrennan@psu.edu
 
% 
% REVISION HISTORY:
% 
% 2023_05_17 by Marcus Putz and Sean Brennan
% - first write of function
%
% 2023_11_02 by Aneesh Batchu, abb6486@psu.edu
% - Modified fcn_SafetyMetrics_create_vehicleTraj to this function to use
%    % the safety metrics library for real vehicle data
%
% 2026_02_16 by Sean Brennan, sbrennan@psu.edu
% - In fcn_SafetyMetrics_showVehicleTrajandMetricInputs
%   % * Formatted into standard form

% TO DO:
% 
% - fill in to-do items here.

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
        narginchk(MAX_NARGIN-2,MAX_NARGIN);

		% Validate the time input is a 1 column
		fcn_DebugTools_checkInputsToFunctions(time, '1column_of_numbers');

		% Validate the vehicleTraj input is a 2 column
		fcn_DebugTools_checkInputsToFunctions(vehicleTraj, '2column_of_numbers');

		% % Validate the metricInputs input is a 2 column
		% fcn_DebugTools_checkInputsToFunctions(metricInputs, '2column_of_numbers');
    end
end

% Does user want to specify object?
object = 0;
if 4 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        object = temp; 
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


% time
time_total = time;

% x coordinates of the vehicle trajectory
x_vehicleTraj = vehicleTraj(:,1);
% y coordinates of the vehicle trajectory
y_vehicleTraj = vehicleTraj(:,2);

% yaw of the vehicle
yawVehicle = fcn_INTERNAL_caculate_yaw(x_vehicleTraj,y_vehicleTraj);
yawVehicle(isnan(yawVehicle)) = 0;

% lane boundaries and center lines
total_laneBoundaries = size(metricInputs,2)/2;

if 2 == total_laneBoundaries 

    leftLane = metricInputs(:,1:2);
    rightLane = metricInputs(:,3:4);

    laneBoundaries = {leftLane,rightLane};

    centerLane = [mean(leftLane(:,1)+rightLane(:,1),2), mean(leftLane(:,2)+rightLane(:,2),2)];
    centerLines = {centerLane}; %centerLines

elseif 3 == total_laneBoundaries 

    Left_leftLane = metricInputs(:,1:2);
    leftLane = metricInputs(:,3:4);
    rightLane = metricInputs(:,5:6);

    laneBoundaries = {Left_leftLane,leftLane,rightLane}; 

    Left_centerLane = [mean(Left_leftLane(:,1)+leftLane(:,1),2), mean(Left_leftLane(:,2)+leftLane(:,2),2)];
    Right_centerLane = [mean(leftLane(:,1)+rightLane(:,1),2), mean(leftLane(:,2)+rightLane(:,2),2)];

    centerLines = {Left_centerLane,Right_centerLane}; %centerLines

end

% If the objects exist, define Flag object == 1
if object
    flagObject = 1; 
else
    flagObject = 0;
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
    
    figure(figNum);

    hold on
    grid on

    plot(x_vehicleTraj, y_vehicleTraj, LineWidth=1.5, DisplayName='Vehicle Trajectory');
    
    lane_width = 12/3.281;
    axis([-1 x_vehicleTraj(end) -2*lane_width 2*lane_width]);
    xlabel('x');
    ylabel('y');

    if 2 == total_laneBoundaries
        plot(leftLane(:,2), leftLane(:,2), LineWidth=1.5, DisplayName='Left Lane');
        plot(rightLane(:,2), rightLane(:,2), LineWidth=1.5, DisplayName='Right Lane');
    end

    if 3 == total_laneBoundaries
        plot(Left_leftLane(:,1), Left_leftLane(:,2), '-k',LineWidth=1.5, DisplayName='Lane Boundaries');
        plot(leftLane(:,1), leftLane(:,2), '--k' ,LineWidth=1.5, DisplayName='Center Lane'); 
        plot(rightLane(:,1), rightLane(:,2), '-k' , LineWidth=1.5, DisplayName='');
        
    end
    % Plot HERE
end

if flag_do_debug
    fprintf(fileID,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
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

function [yaw] = fcn_INTERNAL_caculate_yaw(x,y)
%calulate the Yaw angle by taking the current point and the
%previous point and calculating the atan of that line and the
%origin
previous_point_x = x(1);
previous_point_y = y(1);
yaw = 0*x; % Initialize yaw values

for i = 1:length(x)
    current_point_x = x(i);
    current_point_y = y(i);

    slope = (current_point_y - previous_point_y)/(current_point_x - previous_point_x);

    yaw(i) = atan(slope);

    previous_point_x = x(i);
    previous_point_y = y(i);

end
end
