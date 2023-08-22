function newData = fcn_AVConsistency_addDisTravel(data)
% fcn_AVConsistency_addDisTravel.m
% This function calculates the distance traveled by vehicles measured from 
% the beginning when the vehicle spawns into the SUMO simulation. The original
% data in SUMO measures vehicle position from the start of the current lane,
% which doesn't cater to most of our data processing needs. This function 
% remedies that by recalculating the distance from the beginning of the simulation.
%
% FORMAT:
%
%       newData = fcn_AVConsistency_addDisTravel(data)
%
% INPUTS:
%       data: The input data from SUMO, usually in table format, with x and y coordinates of vehicles.
%
% OUTPUTS:
%       newData: The modified data with an added column for distance traveled by each vehicle.
%
% DEPENDENCIES:
%       NA.
%
% EXAMPLES:
%       See script_AVConsistency_Demo.m for a full test suite. 
%
% This function was written by Wushuang
% Questions or comments? Contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 08 21: Initial creation of the function.
%
% TO DO:
%
% -- Add any future improvements or changes here.

flag_do_debug = 1; % Flag to show function info in UI
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
    if nargin ~= 1 
        error('Incorrect number of input arguments')
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


    % Initialize a column in the table for the total distance traveled
    data.totalStation = zeros(height(data), 1);

    % Extract unique vehicle IDs from the data
    vehicle_ids = unique(data.vehicle_id);

    % Loop through each unique vehicle ID
    for i = 1:length(vehicle_ids)
        % Fetch the current vehicle ID
        vehicle_id = vehicle_ids{i};

        % Identify rows in the data corresponding to this vehicle
        vehicle_rows = strcmp(data.vehicle_id, vehicle_id);

        % Extract x and y coordinates for the current vehicle
        x = data.vehicle_x(vehicle_rows);
        y = data.vehicle_y(vehicle_rows);

        % Compute the distance traveled for the current vehicle based on x and y coordinates
        deltaDisTravel = [0; sqrt(diff(x).^2 + diff(y).^2)];

        % Append the computed distance traveled to the table
        data.disTravel(vehicle_rows) = cumsum(deltaDisTravel);
    end

    % Return the data with the added distance traveled column
    newData = data; 

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
