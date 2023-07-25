% This is the test script to exercise function fcn_spacingBtwAVNLeadVeh.
% For more details, see fcn_acceleVector.m

% Author: Wushuang Bai
% Revision history: 
% 20230723 first write of code


% read in data
fcdData = readtable('fcdTestData.csv');
% input vehicle id to query
avID = 'f_0.10';
figNum = 10;
% run the function 
[accelerationMagnitude, accelerationAngle] = fcn_acceleVector(fcdData, avID, figNum);