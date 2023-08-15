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
function [avTime,spacing,nearestVehID] = fcn_spacingBtwAVNLeadVeh(fcdData, avID,figNum)

    % Find the rows corresponding to the AV
    avRows = strcmp(fcdData.vehicle_id, avID);
    
    % Extract the positions and times of the AV
    avPosition = fcdData.totalStation(avRows);
    avTime = fcdData.timestep_time(avRows);
    
    % Initialize the spacing array
    spacing = zeros(size(avPosition));
    nearestVehID = cell(length(avTime),1);
    % For each time step...
    for i = 1:length(avTime)
        % selected data
        selectedData = fcdData(fcdData.timestep_time == avTime(i),:);


        % Find the positions of the vehicles that are ahead of the AV
        positionDiff = selectedData.totalStation - avPosition(i);
      
        minPositive = min(positionDiff(positionDiff > 0));
        
        % If there are any vehicles ahead...
        if ~isempty(minPositive)
            
            ind = find(positionDiff ==minPositive);            
            % Calculate the spacing to the nearest lead vehicle
            spacing(i) = positionDiff(ind);
            nearestVehID{i} = selectedData.vehicle_id(ind);

        else
            % If there are no vehicles ahead, set the spacing to NaN
            spacing(i) = NaN;
            nearestVehID{i} = NaN;
        end
    end
    figure(figNum);
    subplot(2,1,1)
    plot(avPosition,spacing,'LineWidth',2);
    xlabel('Station (m)');
    ylabel('Spacing (m)');

    subplot(2,1,2)
    plot(avTime,spacing,'LineWidth',2);
    xlabel('Time (sec)');
    ylabel('Spacing (m)');

end
