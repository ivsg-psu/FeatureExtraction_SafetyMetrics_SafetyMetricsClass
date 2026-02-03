function fcn_AVConsistency_siteSpecificSpeedDisparity(data,vehID,varargin,speed_distribution)
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

% Define the increments
increments = 0:100:1500;

% Initialize arrays to store mean and standard deviation values
mean_values = zeros(size(increments));
std_values = zeros(size(increments));

% Loop through each unique vehicle ID in the data
for i = 1:length(unique_vehicles)
    % Extract data specific to the current vehicle ID
    vehicle_data = data(strcmp(data.vehicle_id, unique_vehicles{i}), :);
    % Plot speed vs. snapStation for the current vehicle in black
    h1 = plot(vehicle_data.snapStation, vehicle_data.speed_filtered, 'k');
   
    if speed_distribution
        % Initialize arrays to store interpolated data for the current vehicle
        interpolated_speed = zeros(size(increments));
        
        % Interpolate data for the current vehicle and increment
        for j = 1:length(increments)
            interpolated_speed(j) = interp1(vehicle_data.snapStation, vehicle_data.speed_filtered, increments(j), 'linear');
        end
        
        % Calculate and accumulate the mean values
        mean_values = mean_values + interpolated_speed;
        % disp(interpolated_speed);
        % Store the interpolated data for standard deviation calculation
        std_values = [std_values; interpolated_speed];
    end
end

% Extract data specific to the target vehicle (specified by vehID)
target_vehicle = data(strcmp(data.vehicle_id, vehID), :);

% Plot speed vs. snapStation for the target vehicle in red
h2 = plot(target_vehicle.snapStation, target_vehicle.speed_filtered, 'r','LineWidth',2);

% Label the axes of the plot
xlabel('Station (m)');
ylabel('Speed (m/s)');

% Add a legend to the plot to distinguish between target vehicle and others
legend([h1,h2],'Human driven Vehicles', 'AV');

% Calculate the final mean values
mean_values = mean_values / length(unique_vehicles);

% Calculate the standard deviation using all interpolated data
std_values = std(std_values);

if speed_distribution
    % Create a figure for the plot
    figure;
    
    std_values_2std = 2 * std_values;
    % Plot the mean values with a shaded area for two standard deviations
    errorbar(increments, mean_values, std_values_2std, 'k.-');
    hold on; % Hold the current plot to add more data

    % Plot speed vs. snapStation for the target vehicle in red
    plot(target_vehicle.snapStation, target_vehicle.speed_filtered, 'r');

    title('Mean Speed with 2 Standard Deviations vs. snapStation Increments');
    xlabel('snapStation Increments');
    ylabel('Mean Speed');

    work_start = 1067; % work zone start point
    work_end = 1387; % work zone end point
    % Create a vertical line at the specified x-coordinate
    xline(work_start, 'b', 'LineWidth', 2); 
    hold on; % Hold the current plot to add more data
    % Create a vertical line at the specified x-coordinate
    xline(work_end, 'b', 'LineWidth', 2);
    % Add a legend to the plot
    legend('Mean Speed with 2 Standard Deviations', 'AV','Work zone starts at x = 1067', 'Work zone ends at x = 1387'); 
    grid on;
    set(gca, 'GridAlpha', 0.2); % Set grid alpha to 1 for the current axes

end

% Display the plots
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
