function [station, acceleration_longitudinal, acceleration_lateral] = fcn_AVConsistency_acceleVector_filtered_speed(vehData,filterFlag,varargin)
% fcn_AVConsistency_acceleVector_filtered_speed.m
% This function calculates the acceleration vector (both in x and y directions) 
% of a vehicle, based on either filtered or unfiltered vehicle position. The results are 
% visualized in a quiver plot, displaying the total acceleration vector of the 
% vehicle aligned with X and Y directions.
%
% FORMAT:
%
%       [station, acceleration_x, acceleration_y] = 
%       fcn_AVConsistency_acceleVector_filtered_speed(vehData, filterFlag)
%
% INPUTS:
%       vehData: The vehicle data, usually in table format, containing columns 
%                such as vehicle_x, vehicle_y, vehicle_speed, and timestep_time.
%       filterFlag: A flag to determine whether to use filtered (1) or unfiltered (0) speed.
%
% OUTPUTS:
%       station: The station (or snapStation) of the vehicle.
%       acceleration_x: The acceleration of the vehicle in the x-direction.
%       acceleration_y: The acceleration of the vehicle in the y-direction.
%
% DEPENDENCIES:
%       MATLAB's basic functions for table manipulation and plotting.
%
% EXAMPLES:
%
%       See script_AVConsistency_Demo.m for a full test suite. 
%
% This function was written by Wushuang
% Questions or comments? Contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 08 21: Initial creation of the function.
% 2023 08 22: added comments
% TO DO:
%
% -- Add any future improvements or changes here.
flag_do_debug = 0; % Flag to show function info in UI
flag_do_plots = 0; % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
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

if flag_check_inputs == 1
    % Are there the right number of inputs?
    if nargin < 2 || nargin > 3
        error('Incorrect number of input arguments')
    end
end

% Does user want to show the plots?
if 3 == nargin
    fig_num = varargin{1};
    figure(fig_num);
    flag_do_plots = 1;
else
    if flag_do_debug
        fig = figure;
        fig_num = fig.Number;
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


    % Extract relevant position and speed data based on filterFlag
    if 1 == filterFlag
        vehicle_x = vehData.vehicle_x_filtered;
        vehicle_y = vehData.vehicle_y_filtered;
    elseif 0 == filterFlag
        vehicle_x = vehData.vehicle_x;
        vehicle_y = vehData.vehicle_y;
    end
    vehicle_speed = vehData.speed_filtered;
    timestep_time = vehData.timestep_time;
    % Convert yaw angle from degrees to radians
    vehicle_angle_rad = deg2rad(vehData.vehicle_angle);
    % Compute the differences in position, time, and speed to derive acceleration
    % It calculates the differences between consecutive position values in the x and y directions (dx and dy).
    dx = diff(vehicle_x); % x sped differences
    dy = diff(vehicle_y); % y speed differences
    dt = diff(timestep_time);
    dv = diff(vehicle_speed); % filtered speed

    % Determine the acceleration magnitude (first derivative of speed)
    % It computes the acceleration magnitude by dividing the differences in speed (dv) by the differences in time (dt). 
    acceleration_magnitude = dv ./ dt;

    % Normalize the position changes to get the direction of movement
    % It calculates the magnitude of position changes by computing the Euclidean distance (sqrt(dx^2 + dy^2)).
    % It computes the direction of movement in the x and y directions (dir_x and dir_y) by dividing the changes in 
    % position by the magnitude.
    magnitude = sqrt(dx.^2 + dy.^2);
    dir_x = dx ./ magnitude;
    dir_y = dy ./ magnitude;

    % Compute acceleration components in x and y directions
    % It calculates the acceleration components in the x and y directions by multiplying the acceleration magnitude 
    % by the direction vectors (dir_x and dir_y) for each time step.
    acceleration_x = acceleration_magnitude(2:end) .* dir_x(2:end);
    acceleration_y = acceleration_magnitude(2:end) .* dir_y(2:end);

    % Extract station data for plotting
    station = vehData.snapStation(3:end);
    % Initialize arrays for longitudinal and lateral accelerations
    acceleration_longitudinal = zeros(size(acceleration_x));
    acceleration_lateral = zeros(size(acceleration_y));
    % Compute longitudinal and lateral accelerations
    for i = 1:length(acceleration_x)
        % Create the rotation matrix for each timestep
        rotation_matrix = [cos(vehicle_angle_rad(i)) -sin(vehicle_angle_rad(i));
                           sin(vehicle_angle_rad(i))  cos(vehicle_angle_rad(i))];
        
        % Rotate the acceleration vector from ENU to vehicle frame
        acceleration_vehicle_frame = rotation_matrix * [acceleration_x(i); acceleration_y(i)];
        
        % Assign the rotated accelerations to longitudinal and lateral components
        acceleration_longitudinal(i) = acceleration_vehicle_frame(1);
        acceleration_lateral(i) = acceleration_vehicle_frame(2);
    end


%% Any debugging?
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
if 1==flag_do_plots
    % Create a quiver plot to visualize the acceleration vectors
    figure(fig_num);
    subplot(2,1,1);
    plot(station,acceleration_x,'k','LineWidth',2);
    xlabel('Station (m)');
    ylabel('Acceleration in X direction (m/s^2)');
    %xlim([1200 1500]);
    subplot(2,1,2);
    plot(station,acceleration_y,'k','LineWidth',2);  
    xlabel('Station (m)');
    ylabel('Acceleration in Y direction (m/s^2)');
    %xlim([1200 1500]);

end
end