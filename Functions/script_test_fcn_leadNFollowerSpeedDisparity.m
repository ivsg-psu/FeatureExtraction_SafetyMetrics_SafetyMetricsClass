% This is the test script to exercise function fcn_spacingBtwAVNLeadVeh.
% For more details, see fcn_leadNFollowerSpeedDisparity.m

% Author: Wushuang Bai
% Revision history: 
% 20230731 first write of code



%% case 1, AV leader-specific speed disparity
% read in data
fcdData = readtable('fcdTestData_laneclosure.csv');
% add total station to the data
fcdData = fcn_addStation(fcdData); 
% input vehicle id to query
avID = 'f_0.10';
% sensor range
sensorRange = 100; 
relativeTo = 'lead'; % check the speed disparity between the AV and the vehicle ahead 
figNum = 10;
[avTime,avPosition,nearestVehID,speedDisparity] = fcn_leadNFollowerSpeedDisparity(fcdData, sensorRange, avID, relativeTo,figNum);


%% case 2, AV follow-specific speed disparity
% read in data
fcdData = readtable('fcdTestData_laneclosure.csv');
% add total station to the data
fcdData = fcn_addStation(fcdData); 
% input vehicle id to query
avID = 'f_0.10';
% sensor range
sensorRange = 100; 
relativeTo = 'follow';
figNum = 20;
[avTime,avPosition,nearestVehID,speedDisparity] = fcn_leadNFollowerSpeedDisparity(fcdData, sensorRange, avID, relativeTo,figNum);
