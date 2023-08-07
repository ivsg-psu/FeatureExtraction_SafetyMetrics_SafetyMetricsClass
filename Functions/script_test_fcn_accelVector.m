% This is the test script to exercise function fcn_spacingBtwAVNLeadVeh.
% For more details, see fcn_acceleVector.m

% Author: Wushuang Bai
% Revision history: 
% 20230723 first write of code


% read in data
data = readtable('fcdTestData_laneClosure.csv');
% input vehicle id to query
avID = 'f_0.9';
avData = fcn_getAVData(data,avID);
% figure number
figNum = 10;
% run the function 
[time_vector, acceleration_x, acceleration_y] = fcn_acceleVector(avData,figNum);
