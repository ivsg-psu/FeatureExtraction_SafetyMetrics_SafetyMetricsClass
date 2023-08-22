function [station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_position(vehData,filterFlag,varargin)
% fcn_AVConsistency_acceleVector_filtered_position.m
% This function computes the total acceleration vector of a vehicle, measured at its center of gravity. 
% The vector's magnitude and direction provide insights into cornering, braking, and tractive forces. 
% Understanding these forces is crucial in determining the friction utilization of the AV at different 
% locations, particularly in work zones. This information helps ascertain the remaining maneuvering 
% capacity of the AV—how it may respond to sudden obstacles without skidding, for instance.
%
% FORMAT:
%
%       [station, acceleration_x, acceleration_y] = 
%       fcn_AVConsistency_acceleVector_filtered_position(vehData, filterFlag)
%
% INPUTS:
%       vehData: Vehicle data, usually in table format, containing columns like vehicle_x, vehicle_y, and timestep_time.
%       filterFlag: A flag to decide whether to use filtered (1) or unfiltered (0) positions.
%
% (optional)
%       varargin: figure number
%
% OUTPUTS:
%       station: The station (or snapStation) of the vehicle.
%       acceleration_x: The acceleration of the vehicle in the x-direction.
%       acceleration_y: The acceleration of the vehicle in the y-direction.
%
% DEPENDENCIES:
%      NA.
%
% EXAMPLES:
%
%        See script_AVConsistency_Demo.m for a full test suite. 
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

flag_do_debug = 1; % Flag to show function info in UI
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


    % Extract position data based on filterFlag
    if 1 == filterFlag
        vehicle_x = vehData.vehicle_x_filtered;
        vehicle_y = vehData.vehicle_y_filtered;
    elseif 0 == filterFlag
        vehicle_x = vehData.vehicle_x;
        vehicle_y = vehData.vehicle_y;
    end
    timestep_time = vehData.timestep_time;

    % Compute the differences in position and time to derive velocities
    dx = diff(vehicle_x);
    dy = diff(vehicle_y);
    dt = diff(timestep_time);

    % Determine velocity components in x and y directions
    velocity_x = dx ./ dt;
    velocity_y = dy ./ dt;

    % Compute acceleration components in x and y directions based on velocity changes
    acceleration_x = diff(velocity_x) ./ dt(2:end);
    acceleration_y = diff(velocity_y) ./ dt(2:end);

    % Extract station data for plotting
    station = vehData.snapStation(3:end);
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
    quiver(station, zeros(size(acceleration_x)), acceleration_x, acceleration_y, 'AutoScale', 'on');
    xlabel('Time (s)');
    ylabel('Total Acceleration (m/s^2)');
    if 1 == filterFlag
    title('Acceleration using filtered position');
    elseif 0 == filterFlag
    title('Acceleration using nonfiltered position');
    end
    grid on;
end
end
