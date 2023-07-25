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

function [accelerationMagnitude, accelerationAngle] = fcn_acceleVector(fcdData, avID, figNum)
    
    % Find the rows corresponding to the AV
    avRows = strcmp(fcdData.vehicle_id, avID);
    
    % Extract the speed, angle, and time of the AV
    avSpeed = fcdData.vehicle_speed(avRows);
    avAngle = deg2rad(fcdData.vehicle_angle(avRows)); % Convert angle from degrees to radians
    avTime = fcdData.timestep_time(avRows);
    
    % Calculate the velocity vector of the AV at each time step
    avVelocityX = avSpeed .* cos(avAngle);
    avVelocityY = avSpeed .* sin(avAngle);
    
    % Calculate the change in velocity and time
    deltaVelocityX = diff(avVelocityX);
    deltaVelocityY = diff(avVelocityY);
    deltaTime = diff(avTime);
    
    % Calculate the acceleration vector of the AV at each time step
    accelerationX = deltaVelocityX ./ deltaTime;
    accelerationY = deltaVelocityY ./ deltaTime;
    
    % Calculate the magnitude and angle of the acceleration vector
    accelerationMagnitude = sqrt(accelerationX.^2 + accelerationY.^2);
    accelerationAngle = atan2(accelerationY, accelerationX);
    
    % Plot the acceleration vector as a function of time
    figure(figNum);
    quiver(avTime(2:end), zeros(size(accelerationX)), accelerationX, accelerationY);
    xlabel('Time');
    ylabel('Acceleration');
    title('Total acceleration vector of the AV as a function of time');
end

