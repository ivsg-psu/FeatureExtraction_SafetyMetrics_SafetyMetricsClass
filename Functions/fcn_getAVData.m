% This script queris AV speed from SUMO traffic simulation FCD outputs.
% please see https://sumo.dlr.de/docs/Simulation/Output/FCDOutput.html for
% more details

% INPUTS:
% fcdData: this is the read-in FCD data, usually in table format
% vehicleID: the vehicle ID you want to queri

% OUTPUTS:
% vehicleSpeed: the queried vehicle speed

% Author: Wushuang Bai
% Revision history: 
% 20230721 first write of code 

function vehicleData = fcn_getAVData(fcdData, vehicleID)
    
    % Find the rows corresponding to the specified vehicle ID
    vehicleRows = strcmp(fcdData.vehicle_id,vehicleID);
    
    % Extract the speed of the vehicle
    vehicleData  = fcdData(vehicleRows,:);
end
