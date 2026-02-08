function [time,...
    xTotal,...
    yTotal,...
    yaw, laneBoundaries, centerline, flagObject] = fcn_SafetyMetrics_generateVehicleTraj(TrajectoryTypeString, varargin)
%% fcn_SafetyMetrics_generateVehicleTraj 
% 
% This function generates and plots the selected trajectory. 
% 
% 
% FORMAT:
% 
% [time, xTotal, yTotal, yaw, lanes, centerline, flag_object] = fcn_SafetyMetrics_generateVehicleTraj(traj_type, (figNum))
% 
% INPUTS:
%       TrajectoryTypeString: 
% 
%       Lane change
%       Stop at stop sign
%       Half-lane change around an object
%       Right hand turn
%       Left hand turn
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
%  time: 500x1 matrix of time
% 
%  xTotal:500x1 matrix of x coordinates
% 
%  yTotal:500x1 matrix of y coordinates
% 
%  yaw:500x1 matrix of yaw angles for each xy point
% 
%  centerline: 500xN matrix of x and y coordinates of the centerlines
% 
%  flag_object: a boolean value of if to plot an object. 1 = plot object
% 
% DEPENDENCIES:
% 
%     fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_SafetyMetrics_generateVehicleTraj.m 
%
%       for a full test suite.
% 
% This function was written on 2021_07_11 by Sean Brennan
% Questions or comments? contact sbrennan@psu.edu

% 
% REVISION HISTORY:
% 
% 2023_05_17 by Marcus Putz and Sean Brennan
% - first write of function
% 
% 2026_02_04 by Aneesh Batchu, abb6486@psu.edu
% - Modified centerlane = [xTotal(:)', yTotal(:)'] in Traj == 2 
%   % from [x_lane',yTotal'];
% 
% 2026_02_07 by Aneesh Batchu, abb6486@psu.edu
% - Added DebugTools to check the inputs
% - Added switch cases to generate the trajectory
% - Created INTERNAL functions to generate the trajectories
% - Modified the code to output all the specified outputs for all
%   % trajectory types. Initially, the code was not outputting lanes,
%   % centerline for right and left hand turns. 
% - Modifed name of the function to "fcn_SafetyMetrics_generateVehicleTraj"
%   % from "fcn_SafetyMetrics_create_vehicleTraj"

% TO DO:
% 
% -- fill in to-do items here.

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
        narginchk(1,MAX_NARGIN);

		% Validate the traj_type input that it is a char or string
		fcn_DebugTools_checkInputsToFunctions(TrajectoryTypeString, '_of_char_strings');

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


lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)

switch lower(erase(TrajectoryTypeString, " "))

    case 'lanechange'

        [time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject,...
            x_lane, y_lane_R, y_lane_L, y_lane_L_L] =...
            fcn_INTERNAL_generateLaneChangeTraj(lane_width);


    case 'stoppingatastopsign'

        [time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject,...
            x_lane, y_lane_R, y_lane_L] =...
            fcn_INTERNAL_generateStoppingAtAStopSignTraj(lane_width);

    case 'halflanechange'

        [time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject,...
            x_lane, y_lane_R, y_lane_L, y_lane_L_L] =...
            fcn_INTERNAL_generateHalfLaneChangeTraj(lane_width);

    case 'righthandturn'

        [time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject,...
            left_lane, right_lane] =...
            fcn_INTERNAL_generateRightHandTurnTraj(lane_width);

    case 'lefthandturn'

        [time, xTotal, yTotal, yaw, laneBoundaries, centerline, flagObject,...
            left_lane, right_lane] =...
            fcn_INTERNAL_generateLeftHandTurnTraj(lane_width);

    otherwise

        error([' "%s" is not a valid trajectory. \n Valid trajectories: Lane Change, Half Lane Change,' ...
            ' Stopping at a Stop Sign, Right Hand Turn, Left Hand Turn'], TrajectoryTypeString)

end


% Make row matrices (1 x 500) into column matrices (500 x 1) 
time = time';
xTotal = xTotal';
yTotal = yTotal';
yaw = yaw';


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

    figure(figNum)
    hold on
    grid on
    xlabel('x');
    ylabel('y');

    switch lower(erase(TrajectoryTypeString, " "))

        case 'lanechange'

            plot(xTotal, yTotal);
            plot(x_lane, y_lane_R);
            plot(x_lane, y_lane_L_L);
            plot(x_lane, y_lane_L);

            axis([-1 xTotal(end) -2*lane_width 2*lane_width]);
            title('Modified Sigmoid Function lane change');

        case 'stoppingatastopsign'

            plot(xTotal, yTotal);
            plot(x_lane, y_lane_R);
            plot(x_lane, y_lane_L);

            axis([-1 xTotal(end) -2*lane_width 2*lane_width]);
            title('Stopping at a stop sign');


        case 'halflanechange'

            plot(xTotal, yTotal);
            plot(x_lane, y_lane_R);
            plot(x_lane, y_lane_L_L);
            plot(x_lane, y_lane_L);

            axis([-1 xTotal(end) -2*lane_width 2*lane_width]);
            title('Half-lane change with object');

        case 'righthandturn'

            plot(xTotal, yTotal);

            plot(left_lane(:,1),left_lane(:,2));
            plot(right_lane(:,1),right_lane(:,2));

            %axis([-1, xTotal(end)+20, 10, yTotal(end)-10]);
            title('Right turn');

        case 'lefthandturn'

            plot(xTotal, yTotal);
            plot(left_lane(:,1),left_lane(:,2));
            plot(right_lane(:,1),right_lane(:,2));

            %axis([-1, xTotal(end)+20, 10, yTotal(end)-10]);
            title('Left turn');

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


function y = fcn_INTERNAL_modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)
% MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters

% Compute the adjusted parameters
a = a_factor / (t1 - t0);
b = b_factor * (t0 + t1) / 2;

% Compute the modified sigmoid function
y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));
end


function [yaw] = fcn_INTERNAL_caculate_yaw(x,y)
% Calulate the Yaw angle by taking the current point and the
% previous point and calculating the atan of that line and the
% origin
previous_point_x = x(1);
previous_point_y = y(1);

% Preallocate yaw variable
yaw = zeros(length(x(:,1)),1);

for i = 1:length(x)
    current_point_x = x(i);
    current_point_y = y(i);

    slope = (current_point_y - previous_point_y)/(current_point_x - previous_point_x);
    
    yaw(i) = atan(slope);

    previous_point_x = x(i);
    previous_point_y = y(i);

end
end

function [time, xTotal, yTotal, yaw, lanes, centerline, flag_object,...
    x_lane, y_lane_R, y_lane_L, y_lane_L_L] =...
    fcn_INTERNAL_generateLaneChangeTraj(lane_width)

% Specify the x coordinates
x1 = 1:1:100;
x2 = 101:1:200;
x3 = 201:1:300;
x4 = 301:1:400;
x5 = 401:1:500;

xTotal = [x1,x2,x3,x4,x5];

%Specify the first y segments
y1 = zeros(1,100);
y2 = fcn_INTERNAL_modify_sigmoid(x2,101,200,0,lane_width,17,1);
y3 = zeros(1,100)+lane_width;
y4 = fcn_INTERNAL_modify_sigmoid(x4,301,400,lane_width,0,17,1);
y5 = zeros(1,100);

yTotal = [y1,y2,y3,y4,y5];

% Set up the time
time = 1:1:500;

% Calculate the yaw
yaw = fcn_INTERNAL_caculate_yaw(xTotal,yTotal);
yaw(isnan(yaw)) = 0;

% Flag for objects: 0 - No objects, 1 - one object..etc.
flag_object = 0;

% Create the lanes
x_lane = 1:1:xTotal(end);
y_lane_L_L = zeros(1,xTotal(end))+3/2*lane_width; %L_L means the most left lane
y_lane_L = zeros(1,xTotal(end))+lane_width/2;
y_lane_R = zeros(1,xTotal(end))-lane_width/2;

% Create the centerlines
centerline_L = zeros(1,xTotal(end))+lane_width;
centerline_R = zeros(1,xTotal(end))-lane_width;

% Lanes
left_lane = [x_lane',y_lane_L'];
left_left_lane = [x_lane',y_lane_L_L'];
right_lane = [x_lane',y_lane_R'];

% Centerlines of each lane
centerline_left = [x_lane',centerline_L'];
centerline_right = [x_lane',centerline_R'];

% Lanes and Centerliens of corresponding lanes
lanes = {left_left_lane,left_lane,right_lane};
centerline = {centerline_left,centerline_right};

end

% Vehicle will drive 300m and stop at stop sign then continue driving
function [time, xTotal, yTotal, yaw, lanes, centerline, flag_object,...
    x_lane, y_lane_R, y_lane_L] =...
            fcn_INTERNAL_generateStoppingAtAStopSignTraj(lane_width)

% Set up x coordinates
x1 = 1:1:300; %driving up to stop sign
x2 = zeros(1,100)+301;
x3 = 302:1:401;
xTotal = [x1,x2,x3];

% Set up y coordinates
yTotal = zeros(1,500);

% Set up the time
time = 1:1:500;

% Calculate the Yaw
yaw = fcn_INTERNAL_caculate_yaw(xTotal,yTotal);
yaw(isnan(yaw)) = 0;

% Flag for object
flag_object = 0;

% Creating lanes
x_lane = 1:1:xTotal(end);
y_lane_L = zeros(1,xTotal(end))+lane_width/2;
y_lane_R = zeros(1,xTotal(end))-lane_width/2;

% Lanes
left_lane = [x_lane',y_lane_L'];
right_lane = [x_lane',y_lane_R'];

% centerlane = [x_lane',yTotal']; (Original)
centerlane = [xTotal', yTotal']; % Modified by Aneesh Batchu - Feb 4, 2026 - 
lanes = {left_lane,right_lane};

centerline = {centerlane};


end

function [time, xTotal, yTotal, yaw, lanes, centerline, flag_object,...
    x_lane, y_lane_R, y_lane_L, y_lane_L_L] =...
    fcn_INTERNAL_generateHalfLaneChangeTraj(lane_width)

%Specify the x coordinates
x1 = 1:1:200;
x2 = 201:1:300;
x3 = 301:1:500;
xTotal = [x1,x2,x3];

%Specify the first y segments
y1 = zeros(1,200);
y2 = fcn_INTERNAL_modify_sigmoid(x2,201,300,0,lane_width,17,1);
y3 = zeros(1,200)+lane_width;
yTotal = [y1,y2,y3];

% Set up the time
time = 1:1:500;

% Caculate the yaw
yaw = fcn_INTERNAL_caculate_yaw(xTotal,yTotal);
yaw(isnan(yaw)) = 0;

% Flag for objects: 0 - No objects, 1 - one object..etc.
flag_object = 1;

% Creating the lanes
x_lane = 1:1:xTotal(end);
y_lane_L_L = zeros(1,xTotal(end))+3/2*lane_width; % L_L furthest left lane
y_lane_L = zeros(1,xTotal(end))+lane_width/2;
y_lane_R = zeros(1,xTotal(end))-lane_width/2;

% Create the centerlines
centerline_L = zeros(1,xTotal(end))+lane_width;
centerline_R = zeros(1,xTotal(end));

% Lanes
left_lane = [x_lane',y_lane_L'];
left_left_lane = [x_lane',y_lane_L_L'];
right_lane = [x_lane',y_lane_R'];

% Centerlines of each lane
centerline_left = [x_lane',centerline_L'];
centerline_right = [x_lane',centerline_R'];

% Lanes and Centerliens of corresponding lanes
lanes = {left_left_lane,left_lane,right_lane};
centerline = {centerline_left,centerline_right};

end


function [time, xTotal, yTotal, yaw, lanes, centerline, flag_object,...
    left_lane, right_lane] =...
    fcn_INTERNAL_generateRightHandTurnTraj(lane_width)

% X axis driving
x1 = 1:1:200;
y1 = zeros(1,200);

% Making the turn
r = 10;
turn_angle = pi/2;
theta = linspace(0, turn_angle, 100);

x2 = r*sin(theta)+x1(end);
y2 = r*cos(theta)-(r-y1(end));

% Y axis driving
x3 = zeros(1,200)+210;
y3 = -11:-1:-210;

% Concatenate the segments
xTotal = [x1,x2,x3];
yTotal = [y1,y2,y3];

% Flag for objects: 0 - No objects, 1 - one object..etc.
flag_object = 0;

% Set up the time
time = 1:1:500;

% Caculate the yaw
yaw = fcn_INTERNAL_caculate_yaw(xTotal,yTotal);
yaw(isnan(yaw)) = 0;

% Lanes
traj = [xTotal',yTotal']; % Centerline
left_lane = traj + [lane_width/2, lane_width/2];
right_lane = traj - [lane_width/2, lane_width/2];

% Lanes and Centerlines of corresponding lanes
lanes = {left_lane,right_lane};
centerline = {traj};

end


function [time, xTotal, yTotal, yaw, lanes, centerline, flag_object,...
    left_lane, right_lane] =...
    fcn_INTERNAL_generateLeftHandTurnTraj(lane_width)

% X axis driving
x1 = 1:1:200;
y1 = zeros(1,200);

% Making the turn
r = 10;
turn_angle = (pi())/2;
theta = linspace(turn_angle,0, 100);

x2 = r*cos(theta)+x1(end);
y2 = -r*sin(theta)+(r-y1(end));

% Y axis driving
x3 = zeros(1,200)+210;
y3 = 11:1:210;

% Concatenate the segments
xTotal = [x1,x2,x3];
yTotal = [y1,y2,y3];

% Set up the time
time = 1:1:500;

% Caculate the yaw
yaw = fcn_INTERNAL_caculate_yaw(xTotal,yTotal);
yaw(isnan(yaw)) = 0;

% Flag for objects: 0 - No objects, 1 - one object..etc.
flag_object = 0;

% Lanes
traj = [xTotal',yTotal'];
left_lane = traj + [lane_width/2, -lane_width/2];
right_lane = traj + [-lane_width/2, lane_width/2];

% Lanes and Centerlines of corresponding lanes
lanes = {left_lane,right_lane};
centerline = {traj};

end
