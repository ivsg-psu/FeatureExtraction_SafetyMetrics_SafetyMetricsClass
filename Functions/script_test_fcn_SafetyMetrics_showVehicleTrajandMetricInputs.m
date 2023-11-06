%script_test_fcn_SafetyMetrics_showVehicleTrajandMetricInputs.m
% tests fcn_SafetyMetrics_showVehicleTrajandMetricInputs.m

% Revision history
% 2023_11_02 - Aneesh Batchu
% -- wrote the code originally

%% Set up the workspace

clc
close all

%% Examples for basic path operations and function testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ______                           _
% |  ____|                         | |
% | |__  __  ____ _ _ __ ___  _ __ | | ___  ___
% |  __| \ \/ / _` | '_ ` _ \| '_ \| |/ _ \/ __|
% | |____ >  < (_| | | | | | | |_) | |  __/\__ \
% |______/_/\_\__,_|_| |_| |_| .__/|_|\___||___/
%                            | |
%                            |_|
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Example - Half-lane change with object

lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)


time = 1:1:500;
time = time';


%Specify the x coordinates
x1 = 1:1:200;
x2 = 201:1:300;
x3 = 301:1:500;
xtotal = [x1,x2,x3];
%Specify the first y segments
y1 = zeros(1,200);
y2 = fcn_INTERNAL_modify_sigmoid(x2,201,300,0,lane_width,17,1);
y3 = zeros(1,200)+lane_width;
ytotal = [y1,y2,y3];

vehicleTraj = [xtotal' ytotal'];


%object flag
object = 1;
%Creating the lanes
x_lane = 1:1:xtotal(end);
y_lane_L_L = zeros(1,xtotal(end))+3/2*lane_width; % L_L furthest left lane
y_lane_L = zeros(1,xtotal(end))+lane_width/2;
y_lane_R = zeros(1,xtotal(end))-lane_width/2;

metricInputs = [x_lane', y_lane_L_L', x_lane', y_lane_L', x_lane', y_lane_R'];


[time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, 1234);

%% Example - Function lane change

lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)


time = 1:1:500;
time = time';

%Specify the x coordinates
x1 = 1:1:100;
x2 = 101:1:200;

x3 = 201:1:300;

x4 = 301:1:400;
x5 = 401:1:500;
xtotal = [x1,x2,x3,x4,x5];
%Specify the first y segments
y1 = zeros(1,100);
y2 = fcn_INTERNAL_modify_sigmoid(x2,101,200,0,lane_width,17,1);
y3 = zeros(1,100)+lane_width;
y4 = fcn_INTERNAL_modify_sigmoid(x4,301,400,lane_width,0,17,1);
y5 = zeros(1,100);

ytotal = [y1,y2,y3,y4,y5];

vehicleTraj = [xtotal' ytotal'];


%object flag
object = 1;

%Create the lanes
x_lane = 1:1:xtotal(end);
y_lane_L_L = zeros(1,xtotal(end))+3/2*lane_width; %L_L means the most left lane
y_lane_L = zeros(1,xtotal(end))+lane_width/2;
y_lane_R = zeros(1,xtotal(end))-lane_width/2;

metricInputs = [x_lane', y_lane_L_L', x_lane', y_lane_L', x_lane', y_lane_R'];


[time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, 234);

%% Example - Stopping at a stop sign


lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)


time = 1:1:500;
time = time';


% Set up x coordinates
x1 = 1:1:300; %driving up to stop sign
x2 = zeros(1,100)+301;
x3 = 302:1:401;
xtotal = [x1,x2,x3];
% Set up y coordinates
ytotal = zeros(1,500);

vehicleTraj = [xtotal' ytotal'];

%object flag
object = 0;

%Creating lanes
x_lane = 1:1:xtotal(end);
y_lane_L = zeros(1,xtotal(end))+lane_width/2;
y_lane_R = zeros(1,xtotal(end))-lane_width/2;

metricInputs = [x_lane', y_lane_L', x_lane', y_lane_R'];

[time_total, x_vehicleTraj, y_vehicleTraj, yawVehicle, laneBoundaries, centerLines, flagObject] = ...
fcn_SafetyMetrics_showVehicleTrajandMetricInputs(time, vehicleTraj, metricInputs, object, 34);


function y = fcn_INTERNAL_modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)
% MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters

% Compute the adjusted parameters
a = a_factor / (t1 - t0);
b = b_factor * (t0 + t1) / 2;

% Compute the modified sigmoid function
y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));
end

