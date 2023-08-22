% fcn_AVConsistency_preProcessData.m
% This function prepares the raw data from SUMO simulation to use.
% Specifically, it does the following:
% 1. add distance travelled for each vehicle
% 2. snap vehicle's station to the center line 

function data = fcn_AVConsistency_preProcessData(data,pathXY)

data = fcn_AVConsistency_addDisTravel(data);
data = fcn_AVConsistency_addSnapStation(data,pathXY); 

end