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
function [avTime,spacing] = fcn_spacingBtwAVNLeadVeh(fcdData, avID,figNum)

    % Find the rows corresponding to the AV
    avRows = strcmp(fcdData.vehicle_id, avID);
    
    % Extract the positions and times of the AV
    avPosition = fcdData.vehicle_pos(avRows);
    avTime = fcdData.timestep_time(avRows);
    
    % Initialize the spacing array
    spacing = zeros(size(avPosition));
    
    % For each time step...
    for i = 1:length(avTime)
        % Find the positions of all vehicles at this time step
        allPositionsAtThisTime = fcdData.vehicle_pos(fcdData.timestep_time == avTime(i));
        
        % Find the positions of the vehicles that are ahead of the AV
        positionsAhead = allPositionsAtThisTime(allPositionsAtThisTime > avPosition(i));
        
        % If there are any vehicles ahead...
        if ~isempty(positionsAhead)
            % Find the position of the nearest lead vehicle
            nearestLeadPosition = min(positionsAhead);
            
            % Calculate the spacing to the nearest lead vehicle
            spacing(i) = nearestLeadPosition - avPosition(i);
        else
            % If there are no vehicles ahead, set the spacing to NaN
            spacing(i) = NaN;
        end
    end
    figure(figNum);
    plot(avTime,spacing,'.','LineWidth',2);
    xlabel('Time (sec)');
    ylabel('Spacing (m)');

end
