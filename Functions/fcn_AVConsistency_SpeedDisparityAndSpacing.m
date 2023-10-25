function [avTime,avPosition,nearestVehID,speedDisparity,spacing] =  fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo,varargin)
% fcn_AVConsistency_SpeedDisparityAndSpacing.m
% This script calculates the speed disparity and spacing between the input
% vehicle ID and the lead of follower vehicle.
%
% FORMAT:
%
%       [avTime,avPosition,nearestVehID,speedDisparity,spacing] =  fcn_AVConsistency_SpeedDisparityAndSpacing(fcdData, sensorRange, avID, relativeTo,figNum)
%
% INPUTS:
%       (mandatory)
%       data: this is the simulation data from SUMO, usually in table format
%       sensorRange: the detecting range of sensor
%       avID: the ID of the autonomous vehicle
%       relativeTo: it has two options:
%                   'lead': it means the result is calculated based on the
%                   AV and the lead vehicle
%                   'follow': it means the result is calculated based on the
%                   AV and the follow vehicle
%
%     (OPTIONAL INPUTS)
%      fig_num: a figure number to plot results.
%
% OUTPUTS:
%
%       avTime: the simulation time of AV, sec
%       avPosition: the s-coordinate of AV, meters
%       nearestVehID: the nearest lead of follow vehicle ID, depending on
%       the input of relativeTo
%       speedDisparity: the speed disparity of the AV and lead or follow
%       vehicle, depending on the input of relativeTo, m/s
%       spacing: the spacing of the AV and lead or follow
%       vehicle, depending on the input of relativeTo, m/s

% DEPENDENCIES:
% NA
%
% EXAMPLES:
%
% See the script: script_test_fcn_getAVData.m
% for a full test suite.
%
% This function was written on 2023 07 23 by Wushuang Bai
% Questions or comments? contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 07 23 first write of the code
% 2023 08 13 edited comments as per IVSG formats
% 2023 08 17: combined calculation of spacing and speed disparity;
%             added comments;
%
% TO DO:
%
% -- change the total station to snaped s coordinate done
% -- 20231025 : changed speed from filtered speed to raw speed

flag_do_debug = 1; % Flag to show function info in UI
flag_do_plots = 0; % Flag to plot the final results
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end
%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs == 1
    % Are there the right number of inputs?
    if nargin < 4 || nargin > 5
        error('Incorrect number of input arguments')
    end
end

% Does user want to show the plots?
if 5 == nargin
    fig_num = varargin{1};
    figure(fig_num);
    flag_do_plots = 1;
else
    if flag_do_debug
        fig = figure;
        fig_num = fig.Number;
        flag_do_plots = 1;
    end
end
%% Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the rows corresponding to the AV
avRows = strcmp(data.vehicle_id, avID);

% Extract the positions, times, speeds, and lane of the AV
avPosition = data.snapStation(avRows);
avTime = data.timestep_time(avRows);
avSpeed = data.vehicle_speed(avRows);
avLane = data.vehicle_lane(avRows); % Added this line to extract lane information

% Initialize the array
speedDisparity = zeros(size(avPosition));
spacing = zeros(size(avPosition));
nearestVehID = cell(length(avTime),1);

% For each time step...
for ii = 1:length(avTime)
    % selected data
    selectedData = data(data.timestep_time == avTime(ii),:);

    % Filter the selectedData to only vehicles in the same lane as the AV at that time step
    sameLaneVehicles = selectedData(strcmp(selectedData.vehicle_lane, avLane(ii)), :); % Added this line

    if strcmp(relativeTo,'follow')
        % Find the positions of the vehicles that are following of the AV
        positionDiff =  avPosition(ii) - sameLaneVehicles.snapStation; % Modified this line to use sameLaneVehicles

    elseif strcmp(relativeTo,'lead')
        % Find the positions of the vehicles that are leading of the AV
        positionDiff = sameLaneVehicles.snapStation - avPosition(ii); % Modified this line to use sameLaneVehicles
    end

    minPositive = min(positionDiff(positionDiff > 0));

    % If there are any vehicles ahead and within sensor range...
    if ~isempty(minPositive) && minPositive <= sensorRange

        ind = find(positionDiff == minPositive);
        nearestVehID{ii} = sameLaneVehicles.vehicle_id(ind); % Modified this line to use sameLaneVehicles
        speedDisparity(ii) = avSpeed(ii) - sameLaneVehicles.vehicle_speed(ind); % Modified this line to use sameLaneVehicles
        spacing(ii) = positionDiff(ind);
    else
        % If there are no vehicles ahead, set the speed disparity to NaN
        speedDisparity(ii) = NaN;
        spacing(ii) = NaN; % Modified to set to NaN instead of using ind which might not be defined
        nearestVehID{ii} = NaN;
    end
end
%% Any debugging?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_plots
figure(fig_num);
subplot(2,1,1)
plot(avPosition,speedDisparity,'k','LineWidth',2);
xlabel('Station (m)');
ylabel('Speed disparity (m/s)');
%xlim([1200 1500]);
subplot(2,1,2)
plot(avPosition,spacing,'k','LineWidth',2);
xlabel('Station (m)');
ylabel('Spacing');
%xlim([1200 1500]);
end
end
