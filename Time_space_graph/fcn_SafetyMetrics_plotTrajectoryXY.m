function fcn_SafetyMetrics_plotTrajectoryXY( ...
trajectory, ...
vehicle_param, ...
time_interval, ...
flag_object,...
flag_3d_plot, ...
varargin...
)
% fcn_SafetyMetrics_plotTrajectoryXY
% Plotting vehicle using using custom time intervals on a XY cartesian coordinate
% system. THis 
% 
% 
% 
% FORMAT:
% 
% function fcn_SafetyMetrics_plotTrajectoryXY( ...
% trajectory, ...
% vehicle_param, ...
% time_interval, ...
% flag_object,...
% flag_3d_plot, ...
% varargin...
% )
% 
% INPUTS:
% 
%     trajectory: [time,x,y,yaw_angle] 4xn vector
% 
%     vehicle_param: sturcture containing 
%       a: distance from origin to front axle (positive)
%       b: distance from origin to rear axle (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outermost left side to outermost right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
%
%     time_interval: the interval to plot at. This should be a 
%     
%     flag_3d_plot: this is a flag: 1 plots in 3d, 0 plots in 2d 
%       
% 
%     (optional inputs)
%
%     fig_num: any number that acts somewhat like a figure number output. 
%     If given, this forces the variable types to be displayed as output 
%     and as well makes the input check process verbose.
% 
% 
% OUTPUTS:
% 
%
% 
% 
% DEPENDENCIES:
%   fcn_SafetyMetrics_plot_3D_vehicle
%   fcn_SafetyMetrics_plot_2D_vehicle  
% 
% 
% EXAMPLES:
% 
% See the script: script_test_fcn_plot_traj_custom_time_interval
% for a full test suite.
% 
% This function was written on 2023_05_19 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

% 
% REVISION HISTORY:
% 
% 2023_05_17 by Marcus Putz and Sean Brennan
% -- first write of function
%
% TO DO:
% 
% -- fill in to-do items here.

%% Debugging and Input checks
flag_check_inputs = 1; % Set equal to 1 to check the input arguments 
flag_do_plot = 0;      % Set equal to 1 for plotting 
flag_do_debug = 0;     % Set equal to 1 for debugging 

if flag_do_debug
    fig_for_debug = 225;
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
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


if 1 == flag_check_inputs

    % Are there the right number of inputs?
    narginchk(5,6)

%     % Check the AABB input, make sure it is '4column_of_numbers' type
%     fcn_MapGen_checkInputsToFunctions(...
%         AABB, '4column_of_numbers',1);
%  
%     % Check the test_points input, make sure it is '2column_of_numbers' type
%     fcn_MapGen_checkInputsToFunctions(...
%         test_points, '2column_of_numbers');
 
end

% Does user want to show the plots?
if  6== nargin
    fig_num = varargin{end};
else
    if flag_do_debug
        fig = figure;
        fig_for_debug = fig.Number;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% Interpolate the data to the times that are specified in time_interval
% Vq = interp1(X,V,Xq)
time_interval_xq = trajectory(1,1):time_interval:trajectory(1,end);
x_data_to_plot = interp1(trajectory(1,:),trajectory(2,:),time_interval_xq);
y_data_to_plot = interp1(trajectory(1,:),trajectory(3,:),time_interval_xq);
yaw_data_to_plot = interp1(trajectory(1,:),trajectory(4,:),time_interval_xq);

data_to_plot = [time_interval_xq;x_data_to_plot;y_data_to_plot;yaw_data_to_plot];

% plot(data_to_plot(2,:),data_to_plot(3,:))
% hold on

%% At each of the previously interpolated points plot the data.
for i = 1:length(data_to_plot)
    traj = [data_to_plot(1,i),data_to_plot(2,i),data_to_plot(3,i),data_to_plot(4,i)];
    
    if flag_3d_plot
    fcn_SafetyMetrics_plot_3D_vehicle(traj,vehicle_param)
    axis([data_to_plot(2,i)-10 data_to_plot(2,i)+10 data_to_plot(3,i)-10 data_to_plot(3,i)+10 data_to_plot(1,i)-10 data_to_plot(1,i)+10 ]);
    hold on
    if flag_object
        fcn_SafetyMetrics_add_and_plot_object(traj(1,1),[257,1.2]);
        axis([data_to_plot(2,i)-10 data_to_plot(2,i)+10 data_to_plot(3,i)-10 data_to_plot(3,i)+10 data_to_plot(1,i)-10 data_to_plot(1,i)+10 ]);
    end
    hold on
    else
        fcn_SafetyMetrics_plot_2D_vehicle(traj,vehicle_param)
        axis([data_to_plot(2,i)-10 data_to_plot(2,i)+10 -10 +10 ]);
    end
    drawnow
end
if flag_3d_plot
axis([data_to_plot(2,1)+10 data_to_plot(2,end)+10 min(data_to_plot(3,:))-10 max(data_to_plot(3,:))+10 data_to_plot(1,1) data_to_plot(1,end)]);
end
%§
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



if flag_do_plot
    figure(fig_num);
    clf;
    hold on;
    
    % Convert axis-aligned bounding box to wall format
    walls = [AABB(1,1) AABB(1,2); AABB(1,3) AABB(1,2); AABB(1,3) AABB(1,4); AABB(1,1) AABB(1,4); AABB(1,1) AABB(1,2)];
    
    % Plot the walls
    plot(walls(:,1),walls(:,2),'k-');
    
    % Plot the test_points
    
    % plot(...
    %     [test_points(:,1); test_points(1,1)],...
    %     [test_points(:,2); test_points(1,2)],...
    %     '.-');
    plot(test_points(:,1), test_points(:,2),'k.');
    
    % Plot the interior points with green
    plot(test_points(isInside,1),test_points(isInside,2),'go');
    
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§




