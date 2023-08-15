% script_test_fcn_getAVData.m
% This is the test script to exercise function fcn_getAVData.
% For more details, see fcn_getAVData.m
       
% Revision history:
%      2023_07_20
%      -- first write of the code
%      2023_08_12
%      -- comments clean-up

%% Test case 1: get the AV data from a lane closure simulation in SUMO. 
% read in data
data = readtable('TestData_laneclosure.csv'); % please see fcn_getAVData.m for details. 
% add total station
data = fcn_addStation(data);
% input vehicle id to query
vehID = 'f_0.10';
fignum = 55;
% run the function 
vehData = fcn_getAVData(data,vehID,fignum);