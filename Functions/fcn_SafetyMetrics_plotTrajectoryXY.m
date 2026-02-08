function layers = fcn_SafetyMetrics_plotTrajectoryXY(trajectory, vehicleParametersStruct, timeInterval, flag3DPlot, varargin)
%% fcn_SafetyMetrics_plotTrajectoryXY
% 
% This function plots the vehicle trajectory in 2D (in blue color) and
% plots the vehicle in a custom time interval in 3d, with the third axis
% being the time.
%
% FORMAT:
%
% layers = fcn_SafetyMetrics_plotTrajectoryXY(trajectory, vehicle_param,
% time_interval, (figNum)); 
%
% INPUTS:
%
%     trajectory: [time,x,y,yaw_angle] nx4 vector
%
%     vehicleParametersStruct: sturcture containing
%       a: distance from origin to front axle (positive)
%       b: distance from origin to rear axle (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outermost left side to outermost right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
%
%     timeInterval: the interval to plot at.
%
%     flag3DPlot: this is a flag: 1 plots in 3d, 0 plots in 2d
% 
%      (OPTIONAL INPUTS)
%
%     figNum: a figure number to plot results. If set to -1, skips any
%     input checking or debugging, no figures will be generated, and sets
%     up code to maximize speed.
%
% OUTPUTS:
%
%  layers: Struct array with first column being the data for the point of
%  the square representation and the second column being the color of that
%  layer.
%
%
% DEPENDENCIES:
% 
%   fcn_SafetyMetrics_plot_3D_vehicle
%   fcn_SafetyMetrics_plot_2D_vehicle
%   fcn_DebugTools_checkInputsToFunctions
%
% EXAMPLES:
%
%       See the script:
%
%       script_test_fcn_SafetyMetrics_plotTrajectoryXY.m 
%
%       for a full test suite.
%
% This function was written on 2023_05_19 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu
%
% REVISION HISTORY:
%
% 2023_05_17 by Marcus Putz and Sean Brennan
% - first write of function
%
% 2026_02_08 by Aneesh Batchu, abb6486@psu.edu
% - Added DebugTools to check the inputs
% - Modified the function to latest format
% - Created the test script for this function

% TO DO:
% 
% 2026_02_08 by Aneesh Batchu, abb6486@psu.edu
% - Pre-allocate layers variable

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

        % trajectory should have 4 column of numbers
        fcn_DebugTools_checkInputsToFunctions(...
            trajectory, '4column_of_numbers');

        % % vehicle_param is a structure
        % fcn_DebugTools_checkInputsToFunctions(...
        %     vehicleParametersStruct, 'likestructure');

        % timeInterval should have 1 integer
        fcn_DebugTools_checkInputsToFunctions(...
            timeInterval, '1column_of_integers', [1,1]);
        
        % flag3DPlot should have 4 column of numbers
        if ~ismember(flag3DPlot, [0, 1])
            error('Input must be either 0 or 1');
        end

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§

%% Interpolate the data to the times that are specified in time_interval

% Vq = interp1(X,V,Xq)
time_interval_xq = trajectory(1,1):timeInterval:trajectory(end,1);
x_data_to_plot = interp1(trajectory(:,1),trajectory(:,2),time_interval_xq)';
y_data_to_plot = interp1(trajectory(:,1),trajectory(:,3),time_interval_xq)';
yaw_data_to_plot = interp1(trajectory(:,1),trajectory(:,4),time_interval_xq)';

data_to_plot = [time_interval_xq',x_data_to_plot,y_data_to_plot,yaw_data_to_plot];

layers = [];

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

    figure(figNum);

    hold on
    grid on

    if flag3DPlot

        % Sets up the axis so that no matter what the trajectory is the plot
        % shows all the data
        axis([data_to_plot(1,2)-10 data_to_plot(end,2)+10 min(data_to_plot(:,3))-5 max(data_to_plot(:,3))+5 data_to_plot(1,1)-5 data_to_plot(end,1)]);
        view(-40,40);
        set(gca,'DataAspectRatio',[10 round(max(abs(data_to_plot(:,3)))/10+1) 50]) % Scales the axes so that the viewer can understand what is going on
        xlabel('x');
        ylabel('y');
        zlabel('t');

    end
    
   
    % At each of the previously interpolated points plot the data.
    for ith_interpolatedPoint = 1:length(data_to_plot)

        traj_to_plot = [data_to_plot(ith_interpolatedPoint,1),data_to_plot(ith_interpolatedPoint,2),data_to_plot(ith_interpolatedPoint,3),data_to_plot(ith_interpolatedPoint,4)];

        if flag3DPlot

            % Plot the time-space trajectory in red
            [layers(ith_interpolatedPoint).data]=fcn_SafetyMetrics_plot_3D_vehicle(traj_to_plot, vehicleParametersStruct,'r-', figNum); % extract the current layer and keep track of it in layers struct
            layers(ith_interpolatedPoint).color = [1 0 0];

            % Plot the time-space "shadow" in blue
            % Set time equal to zero, keeping everything else
            shadow = traj_to_plot;
            shadow(1) = 0;
            fcn_SafetyMetrics_plot_3D_vehicle(shadow, vehicleParametersStruct, 'b-', figNum);

        else

            % Plots the data but only in 2d. Doesn't return the car layers
            fcn_SafetyMetrics_plot_2D_vehicle(traj_to_plot,vehicleParametersStruct)

            % axis([data_to_plot(2,i)-10 data_to_plot(2,i)+10 -10 +10 ]);
        end
        drawnow
    end

    if ~flag3DPlot

        % Make axis larger when it's 2D
        temp = axis;
        axis_range_x = temp(2)-temp(1);
        axis_range_y = temp(4)-temp(3);
        percent_larger = 0.1;
        axis([temp(1)-percent_larger*axis_range_x, temp(2)+percent_larger*axis_range_x,  temp(3)-percent_larger*axis_range_y, temp(4)+percent_larger*axis_range_y]);

    end

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§




