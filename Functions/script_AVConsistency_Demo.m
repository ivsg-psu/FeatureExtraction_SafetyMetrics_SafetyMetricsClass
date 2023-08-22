% script_AVConsistency_Demo.m 
% This script performs a series of operations to process and analyze
% vehicle data, specifically for the autonomous vehicle (AV) identified by avID.
% The operations include:
% 1. Data pre-processing and addition of total station based on path.
% 2. Retrieving data specific to the AV.
% 3. Computing and plotting the AV's site-specific speed disparity.
% 4. Calculating and plotting lead spacing and speed disparity.
% 5. Calculating and plotting follow spacing and speed disparity.
% 6. Computing and plotting the AV's total acceleration vector under different conditions.
%
% DEPENDENCIES:
% Various functions including:
% - fcn_AVConsistency_preProcessData
% - fcn_AVConsistency_getAVData
% - fcn_AVConsistency_siteSpecificSpeedDisparity
% - fcn_AVConsistency_SpeedDisparityAndSpacing
% - fcn_AVConsistency_acceleVector_filtered_position
% - fcn_AVConsistency_acceleVector_filtered_speed
%
% This script was written by Wushuang
% Questions or comments? Contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 08 21: Initial creation of the script.
% 2023 08 22: Added detailed comments.
%
% TO DO:
%
% -- Any further refinements or additional functionalities.

%% Setup - Add paths and read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Add paths for data and functions
addpath('..\Data');
addpath('..\Functions');

% Read in the data
data = readtable('AVembedded.csv'); % See fcn_getAVData.m for details
pathXY = [0,0;2300,0];

% Pre-process the data by adding total station
data = fcn_AVConsistency_preProcessData(data,pathXY);

%% Retrieve data specific to the AV
avID = 'type_AV'; % Specify vehicle id to query
fignum = 1;      % Figure number
vehData = fcn_AVConsistency_getAVData(data,avID,fignum);

%% Compute and plot site-specific speed disparity for AV
fignum = 2;
fcn_AVConsistency_siteSpecificSpeedDisparity(data,avID,fignum);

%% Calculate and plot lead spacing and speed disparity
sensorRange = 100;
relativeTo = 'lead';
fignum = 3;
[avTime,avPosition,nearestVehID,speedDisparity,spacing] =  ...
fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo,fignum);

%% Calculate and plot follow spacing and speed disparity
sensorRange = 100;
relativeTo = 'follow';
fignum = 4;
[avTime,avPosition,nearestVehID,speedDisparity,spacing] =  ...
fcn_AVConsistency_SpeedDisparityAndSpacing(data, sensorRange, avID, relativeTo,fignum);

%% Compute AV's total acceleration vector under different conditions
filterFlag = 1;
nonFilterFlag = 0;
[station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_position(vehData,filterFlag);
[station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_position(vehData,nonFilterFlag);
[station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(vehData,filterFlag);
[station, acceleration_x, acceleration_y] = fcn_AVConsistency_acceleVector_filtered_speed(vehData,nonFilterFlag);
