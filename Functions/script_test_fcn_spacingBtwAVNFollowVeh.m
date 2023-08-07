% This is the test script to exercise function fcn_spacingBtwAVNFollowVeh.
% For more details, see fcn_spacingBtwAVNFollowVeh.m

% Author: Wushuang Bai
% Revision history: 
% 20230723 first write of code

% read in data
data = readtable('fcdTestData_laneClosure.csv');
% update data
data = fcn_addStation(data);
% input vehicle id to query 
vehID = 'f_0.10';
% run the function 
[simTime,spacing] = fcn_spacingBtwAVNFollowVeh(data,vehID,30);