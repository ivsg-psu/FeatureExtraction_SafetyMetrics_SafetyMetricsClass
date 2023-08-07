% AV total acceleration vector: This is the vector of the acceleration
% measured at the center of gravity of the vehicle, used to determine
% cornering, braking, and tractive forces. This is particularly useful to
% determine friction utilization of the AV at different locations within
% the work zone, and thus the remaining maneuvering envelope. For example,
% if the AV is measured with 0.5 g of lateral acceleration and the skid
% number of the pavement indicates a friction supply of 0.5 (e.g., a Skid
% Number of approximately 50), then this case indicates that the AV would
% not be able to swerve further to avoid work zone vehicles or pedestrians
% without skidding.

% INPUTS: 
% data: SUMO fcd data
% figNum: the figure number

% OUTPUTS: 

function [time_vector, acceleration_x, acceleration_y] = fcn_acceleVector(data,figNum)
    % Load data from CSV file
    %data = readtable(file_path);
    vehicle_x = data.vehicle_x;
    vehicle_y = data.vehicle_y;
    timestep_time = data.timestep_time;

    % Calculate differences in X, Y, and time
    dx = diff(vehicle_x);
    dy = diff(vehicle_y);
    dt = diff(timestep_time);

    % Calculate the components of velocity in the X and Y directions
    velocity_x = dx ./ dt;
    velocity_y = dy ./ dt;

    % Calculate the components of acceleration in the X and Y directions
    acceleration_x = diff(velocity_x) ./ dt(2:end);
    acceleration_y = diff(velocity_y) ./ dt(2:end);

    % Time vector matching the size of the acceleration vectors
    time_vector = timestep_time(3:end);

    % Create a quiver plot
    figure(figNum);
    quiver(time_vector, zeros(size(acceleration_x)), acceleration_x, acceleration_y, 'AutoScale', 'on');
    xlabel('Time (s)');
    ylabel('Total Acceleration (m/s^2)');
    title('Total Acceleration Vector of the Vehicle (Aligned with X and Y Directions)');
    grid on;
end

