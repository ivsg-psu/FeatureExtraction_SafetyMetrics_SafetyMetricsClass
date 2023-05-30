%Test script for seftety metrics plot

close all;
clc;

%% Set up vehicle parameters
vehicle_param.w_vehicle = 69.3/(12*3.281); % the width of the vehicle_param, [m] from 63.9 inches
vehicle_param.length = 106.3/(12*3.281); % the length of the vehicle_param, [m]
vehicle_param.tire_width =  12.5/(12*3.281);  % the width of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.tire_length = 33/(12*3.281);  % the diameter of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.a = 1.4; % Location from the CG to the front axle [m]
vehicle_param.b = 1.4; % Location from the CG to the rear axle [m]
vehicle_param.Lf = 1;% Length from origin to front bumper
vehicle_param.Lr = 1;% Length from origin to front bumper

% % Use a plain tire - no spokes (see fcn_drawTire for details)
% vehicle_param.tire_type = 3;
% 
% % Fill in tire information
% starter_tire = fcn_tire_initTire;
% starter_tire.usage = [];
% for i_tire = 1:4    
%     vehicle_param.tire(i_tire)= starter_tire;
% end
% vehicle_param.yawAngle_radians = 0; % the yaw angle of the body of the vehicle_param [rad]
% vehicle_param.position_x = 0; % the x-position of the vehicle_param [m]
% vehicle_param.position_y =0; % the y-position of the vehicle_param [m]
% vehicle_param.steeringAngle_radians = 0; % the steering angle of the front tires [rad]

%% Get the trajectory

clear trajectory
[trajectory(:,1),trajectory(:,2),trajectory(:,3),trajectory(:,4),flag_object]=fcn_SafetyMetrics_create_vehicleTraj(3,1);

%[trajectory(1,:),trajectory(2,:),trajectory(3,:),trajectory(4,:),flag_object]=fcn_SafetyMetrics_create_vehicleTraj(3,1);
figure(455)
plot3(trajectory(:,2),trajectory(:,3),trajectory(:,1));
grid on;
axis equal;
%% Plot the data
time_interval = 5;
[fig_num]=fcn_SafetyMetrics_plotTrajectoryXY(trajectory,vehicle_param,time_interval, 1);

%% Plot objects
flag_barrel = 1;
if flag_barrel
    object_position = [257,1.2];
    
    x = object_position(1,1);
    y = object_position(1,2);
    
    % generate the points of the object
    % the example shown will be a barrel using dimesions from FHWA.
    % DIA = 23"
    
    dia = 23/39.37; %[m];
    r = dia/2;
    theta = linspace(0,2*pi,50);
    
    x2 = r*sin(theta)+x;
    y2 = r*cos(theta)+y;
    object_vertices = [x2;y2];
end

if flag_object
    fcn_SafetyMetrics_add_and_plot_object(trajectory(:,1),object_vertices,1,fig_num);
end

%% Calculate the unit vector for each point

[u]=fcn_SafetyMetrics_unit_vector(trajectory);
