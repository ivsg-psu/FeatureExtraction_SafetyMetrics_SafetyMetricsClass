% script_test_fcn_getAVData.m
% This is the test script to exercise function fcn_getAVData.
% For more details, see fcn_getAVData.m

% The test data is from SUMO simulation, and has the following fields: 
%  timestep_time: The time step described by the values within this
% timestep-element, seconds
%  vehicle_angle: The angle of the vehicle in navigational standard (0-360
% degrees, going clockwise with 0 at the 12'o clock position), deg
%  vehicle_id: The id of the vehicle
%  vehicle_lane: The id of the current lane.
%  vehicle_pos: The running position of the vehicle measured from the
% start of the current lane, meters
%  vehicle_slope: The slope of the vehicle in degrees (equals the slope of
% the road at the current position), deg
%  vehicle_speed: The speed of the vehicle, m/s
%  vehicle_type: The name of the vehicle type
%  vehicle_x: The absolute X coordinate of the vehicle (center of front
%  bumper). The value depends on the given geographic projection, meters
%  vehicle_y: The absolute Y coordinate of the vehicle (center of front
%  bumper). The value depends on the given geographic projection, meters

% This function was written on 2023 07 23 by Wushuang Bai
% Questions or comments? contact wxb41@psu.edu

% Revision history:
%      2023_07_20
%      -- first write of the code
%      2023_08_12
%      -- comments clean-up

%% Test case 1: get the AV data from a lane closure simulation in SUMO. 
% add path
addpath('..\Data');
addpath('..\Functions');
% read in data
data = readtable('TestData_laneclosure.csv'); % please see fcn_getAVData.m for details. 
% add total station
data = fcn_addStation(data);
% input vehicle id to query
vehID = 'f_0.9';
% figure number
fignum = 55;
% run the function 
vehData = fcn_getAVData(data,vehID,fignum);


