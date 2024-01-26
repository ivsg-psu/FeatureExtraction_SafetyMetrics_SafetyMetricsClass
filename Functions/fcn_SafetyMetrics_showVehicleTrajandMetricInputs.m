function [time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
    fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, varargin)
% fcn_SafetyMetrics_showVehicleTrajandMetricInputs
% This code will plot a vehicle given the x,y,and angle.
% 
% 
% 
% FORMAT:
% 
% time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
%     fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, fig_num)
% 
% INPUTS:
% 
%   time: time taken by the vehicle to complete the trajectory
%   vehicleTraj: x,y coordinates of the vehicle trajectory
%   metricInputs: x,y coordinates of the metric inputs object: object
%   object: object = 1, if there is an object in the trajectory or else its
%           zero
%   fig_num: Enter a number for the plots
%
% OUTPUTS:
%  time: matrix of time
%  x_vehicleTraj:x coordinates of vehicle trajectory
%  y_vehicleTraj:y coordinates of vehicle trajectory
%  yaw: matrix of yaw angles for each xy point of the vehicle trajectory
%  laneBoundaries: cooridantes of the laneBoundaries
%  centerLines: x and y coordinates of the centerlines
%  flag_object: a boolean value of if to plot an object. 1 = plot object
%
% DEPENDENCIES:
% 
% No Dependencies
% 
% EXAMPLES:
% 
% 
% REVISION HISTORY:
% 
% 2023_05_17 by Marcus Putz and Sean Brennan
% -- first write of function
% 2023_11_02 - Aneesh Batchu
% -- Modified fcn_SafetyMetrics_create_vehicleTraj to this function to use
% the safety metrics library for real vehicle data
%
% TO DO:
% 


%% Debugging and Input checks
flag_check_inputs = 0; % Set equal to 1 to check the input arguments 
flag_do_plots = 0;      % Set equal to 1 for plotting 
flag_do_debug = 0;     % Set equal to 1 for debugging 

if flag_do_debug
    fig_for_debug = 225;
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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

if flag_check_inputs
    % Are there the right number of inputs?
    narginchk(3,5);

end

object = 0;
if 4 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        object = temp; 
    end
end

% Does user want to show the plots?
% fig_num = [];
if 5 == nargin
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
        figure(fig_num);
        flag_do_plots = 1; 
    end
else
    if flag_do_debug
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
        for i = 1:length(x)
            current_point_x = x(i);
            current_point_y = y(i);
            
            slope = (current_point_y - previous_point_y)/(current_point_x - previous_point_x);
            
            yaw(i) = atan(slope);
            
            previous_point_x = x(i);
            previous_point_y = y(i);
            
        end
end
