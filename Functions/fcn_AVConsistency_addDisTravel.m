% The FCD data in SUMO has vehicle_pos, however it is measured from the
% start of current lane, which does not apply in most of our data
% processing. This function calculates the total station of vehicles
% measured from the beginning when the vehicle spawns into the simulation.

function newFcdData = fcn_AVConsistency_addDisTravel(data)

% MATLAB script to read the CSV file and calculate distance travelled for each vehicle based on x and y coordinates

% Initialize an empty table for the distance travelled
data.totalStation = zeros(height(data), 1);

% Get the unique vehicle IDs
vehicle_ids = unique(data.vehicle_id);

% For each vehicle
for i = 1:length(vehicle_ids)
    % Get the vehicle ID
    vehicle_id = vehicle_ids{i};

    % Get the rows for this vehicle
    vehicle_rows = strcmp(data.vehicle_id, vehicle_id);

    % Get the x and y coordinates for this vehicle
    x = data.vehicle_x(vehicle_rows);
    y = data.vehicle_y(vehicle_rows);

    % Calculate the distance travelled for this vehicle
    deltaDisTravel = [0; sqrt(diff(x).^2 + diff(y).^2)];

    % Assign the calculated distance travelled to the table
    data.disTravel(vehicle_rows) = cumsum(deltaDisTravel);
end
newFcdData = data; 
end
