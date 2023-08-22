% add path
addpath('..\Data');
addpath('..\Functions');
% read in data
data = readtable('AVembedded.csv'); % please see fcn_getAVData.m for details. 
pathXY = [0,0;2300,0];
% add total station
data = fcn_AVConsistency_preProcessData(data,pathXY);
% input vehicle id to query
vehID = 'type_AV';
% figure number
fignum = 55;
% run the function 
%vehData = fcn_AVConsistency_getAVData(data,vehID,fignum);

    other_vehicles = data(~strcmp(data.vehicle_id, vehID), :);
    
    % Extract data for the specified vehID
    target_vehicle = data(strcmp(data.vehicle_id, vehID), :);
    
    % Plot speed vs. snapStation for all other vehicles in black
    plot(other_vehicles.snapStation, other_vehicles.vehicle_speed, 'k.');
    hold on;
    
    % Plot speed vs. snapStation for the target vehicle in red
    plot(target_vehicle.snapStation, target_vehicle.vehicle_speed, 'r.');
    
    % Add title and labels
    title(['Speed vs. SnapStation for Vehicle ID: ', vehID]);
    xlabel('SnapStation (snapStation)');
    ylabel('Speed');
    
    % Display the legend
    legend('Other Vehicles', vehID);

