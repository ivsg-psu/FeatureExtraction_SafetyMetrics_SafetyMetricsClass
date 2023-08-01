% Spacing between the AV and a lead vehicle: Like the TTC metric for safety,
% this is a metric of the distance between the AV and the nearest vehicle ahead within sensor range.

% INPUTS:
% fcdData:  this is the read-in FCD data, usually in table format
% avID: the autonomous vehicle ID 

% OUTPUTS:
% spacing: the spacing between AV and the nearest lead vehicle, meters
% Author: Wushuang Bai
% Revision history: 
% 20230721 first write of code 
function [avTime,avPosition,nearestVehID,speedDisparity] = fcn_leadNFollowerSpeedDisparity(fcdData, sensorRange, avID, relativeTo,figNum)

    % Find the rows corresponding to the AV
    avRows = strcmp(fcdData.vehicle_id, avID);
    
    % Extract the positions and times of the AV
    avPosition = fcdData.totalStation(avRows);
    avTime = fcdData.timestep_time(avRows);
    avSpeed = fcdData.vehicle_speed(avRows);
    % Initialize the array
    speedDisparity = zeros(size(avPosition));
    
    % For each time step...
    for i = 1:length(avTime)
        % selected data
        selectedData = fcdData(fcdData.timestep_time == avTime(i),:);

        if strcmp(relativeTo,'follow')
        % Find the positions of the vehicles that are following of the AV
        positionDiff =  avPosition(i) - selectedData.totalStation;        
        
        elseif strcmp(relativeTo,'lead')
        % Find the positions of the vehicles that are leading of the AV
        positionDiff = selectedData.totalStation - avPosition(i);
        end
        minPositive = min(positionDiff(positionDiff > 0));
        
        % If there are any vehicles ahead and within sensor range...
        if ~isempty(minPositive) && minPositive <= sensorRange
            
            ind = find(positionDiff ==minPositive);            
            nearestVehID{i} = selectedData.vehicle_id(ind);
            speedDisparity(i) = avSpeed(i) - selectedData.vehicle_speed(ind);

        else
            % If there are no vehicles ahead, set the speed disparity to NaN
            speedDisparity(i) = NaN;
        end
    end
    figure(figNum);
    plot(avPosition,speedDisparity,'LineWidth',2);
    xlabel('Station (m)');
    ylabel('Speed disparity (m/s)');

end
