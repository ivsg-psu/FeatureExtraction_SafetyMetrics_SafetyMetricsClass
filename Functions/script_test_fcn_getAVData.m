% This is the test script to exercise function fcn_getAVData.
% For more details, see fcn_getAVData.m

% read in data
data = readtable('fcdTestData_laneclosure.csv');
% input vehicle id to query
vehID = 'f_0.10';
% run the function 
vehData = fcn_getAVData(data,vehID);