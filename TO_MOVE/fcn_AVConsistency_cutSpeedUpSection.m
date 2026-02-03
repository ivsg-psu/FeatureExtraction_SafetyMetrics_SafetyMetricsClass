function [time, speed] = fcn_AVConsistency_cutSpeedUpSection(vehData)


    % Find the rows corresponding to the specified vehicle ID
    vehicleRows = strcmp(vehData.vehicle_id,vehicleID);
    
    % Extract the vehData of the given vehicle
    vehiclevehData  = vehData(vehicleRows,:);
    % Extract the timestep_time and vehicle_speed columns
    time_steps = vehiclevehData.timestep_time;
    speeds = vehiclevehData.speed_filtered;  

    
    % Find the index where the speed stabilizes
    diff_speeds = abs(diff(speeds));
    stable_idx = find(diff_speeds < 0.01, 1, 'first');    
    % Extract the time and speed at this point
    time = time_steps(stable_idx);
    speed = speeds(stable_idx);

end
