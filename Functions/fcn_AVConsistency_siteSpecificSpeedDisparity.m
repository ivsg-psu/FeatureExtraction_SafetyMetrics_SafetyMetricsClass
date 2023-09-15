function fcn_AVConsistency_siteSpecificSpeedDisparity(data,vehID,varargin)
% fcn_AVConsistency_siteSpecificSpeedDisparity.m
% This script plots the speed versus snapStation of a given vehicle (specified by vehID)
% alongside other vehicles in the data.
%
% FORMAT:
%
%       fcn_AVConsistency_siteSpecificSpeedDisparity(data, vehID, varargin)
%
% INPUTS:
%       data: This is the simulation data from SUMO, usually in table format.
%       vehID: The ID of the target vehicle (e.g., an autonomous vehicle).
%       varargin: Additional optional inputs.
%
% OUTPUTS:
%       A plot showing speed versus snapStation for the target vehicle and other vehicles.
%
% DEPENDENCIES:
% NA
%
% EXAMPLES:
%
%       See script_AVConsistency_Demo.m for a full test suite. 
%
% This function was written by Wushuang
% Questions or comments? contact 2023 08 22
%
% REVISION HISTORY:
%
% 2023 08 21: Initial creation of the script.
% 2023 08 22: Updated to add detailed comments.
%
% TO DO:
%
% -- Further refinements or functionality as required.

% Flags
flag_do_debug = 1; % Flag to show function info in UI
flag_do_plots = 0; % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking
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
    if nargin < 2 || nargin > 4
        error('Incorrect number of input arguments')
    end
end

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
% Extract unique vehicle IDs from the data, excluding the specified vehID
unique_vehicles = unique(data.vehicle_id);
unique_vehicles = unique_vehicles(~strcmp(unique_vehicles, vehID));

% Initialize a new figure and hold it to overlay multiple plots
figure(fig_num);
hold on;

% Loop through each unique vehicle ID in the data
for i = 1:length(unique_vehicles)
    % Extract data specific to the current vehicle ID
    vehicle_data = data(strcmp(data.vehicle_id, unique_vehicles{i}), :);
    % Plot speed vs. snapStation for the current vehicle in black
    h1 = plot(vehicle_data.snapStation, vehicle_data.speed_filtered, 'k-');
end

% Extract data specific to the target vehicle (specified by vehID)
target_vehicle = data(strcmp(data.vehicle_id, vehID), :);

% Plot speed vs. snapStation for the target vehicle in red
h2 = plot(target_vehicle.snapStation, target_vehicle.speed_filtered, 'r-');

% Label the axes of the plot
xlabel('Station (m)');
ylabel('Speed (m/s)');

% Add a legend to the plot to distinguish between target vehicle and others
legend([h1,h2],'Human driven Vehicles', 'AV');
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
% NA. 
end
