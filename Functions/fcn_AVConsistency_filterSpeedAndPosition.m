function sortedData = fcn_AVConsistency_filterSpeedAndPosition(data)
data(end,:) = [];
uniqueVehID = unique(data.vehicle_id);
cellVehData = cell(length(uniqueVehID),1);
for ii = 1:length(uniqueVehID)
% Find the rows corresponding to the specified vehicle ID
vehicleRows = strcmp(data.vehicle_id,uniqueVehID(ii));

% Extract the data of the given vehicle
vehicleData  = data(vehicleRows,:);
%fprintf('Data length: %d\n', size(vehicleData));

% Design a Butterworth low-pass filter
% Define sampling frequency 
Fs = 10; % Hz
% Define cutoff frequency for the low-pass filter
Fc = 0.1; % Hz (adjust this value based on desired smoothness)
% Design a Butterworth low-pass filter 
%[N, Wn] = buttord(Fc/(Fs/2), 1.5*Fc/(Fs/2), 3, 20);
[b, a] = butter(1, 0.1/(Fs/2));

vehicleData.vehicle_x_filtered = filtfilt(b,a,vehicleData.vehicle_x);
vehicleData.vehicle_y_filtered = filtfilt(b,a,vehicleData.vehicle_y);
vehicleData.speed_filtered = filtfilt(b,a,vehicleData.vehicle_speed);
vehicleData = fcn_AVConsistency_cutSpeedUpSection(vehicleData);
cellVehData{ii} = vehicleData;
clear vehicleData; 
end

sortedData = vertcat(cellVehData{:});
sortedData = sortrows(sortedData,'timestep_time');
end

function vehData = fcn_AVConsistency_cutSpeedUpSection(vehData)

    speeds = vehData.speed_filtered;  
    
    % Find the index where the speed stabilizes
    diff_speeds = abs(diff(speeds));
    stable_idx = find(diff_speeds < 0.01, 1, 'first');    
    vehData(1:stable_idx-1,:) = [];

end
