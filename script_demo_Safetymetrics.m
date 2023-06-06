%Test script for seftety metrics plot

close all;
clc;

%% Set up vehicle parameters
vehicle_param.w_vehicle = 69.3/(12*3.281); % the width of the vehicle_param, [m] from 63.9 inches
vehicle_param.length = 106.3/(12*3.281); % the length of the vehicle_param, [m]
vehicle_param.tire_width =  12.5/(12*3.281);  % the width of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.tire_length = 33/(12*3.281);  % the diameter of the wheel [m], assuming 12.5 inch width and 3.281 feet in a meter
vehicle_param.a = 1; % Location from the CG to the front axle [m]
vehicle_param.b = 1; % Location from the CG to the rear axle [m]
vehicle_param.Lf = 1.3;% Length from origin to front bumper
vehicle_param.Lr = 1.3;% Length from origin to front bumper

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
    %object_position = [257,1.2];
    object_position = [257,0];
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
    [object]=fcn_SafetyMetrics_add_and_plot_object(trajectory,object_vertices,object_position,1,vehicle_param,fig_num);
end

%% Calculate the unit vector for each point

[u]=fcn_SafetyMetrics_unit_vector(trajectory);
patch(object)

%% Using the unit vector project out two rays off set from the center line representing the vehicle length
for i = 1:length(u)
    dir = [u(i,2),u(i,3),u(i,1)];
    pos = [trajectory(i,2),trajectory(i,3),trajectory(i,1)];
    
    vert1 = object.Vertices(object.Faces(:,1),:);
    vert2 = object.Vertices(object.Faces(:,2),:);
    vert3 = object.Vertices(object.Faces(:,3),:);
    
    [intersect, dis, y, v, xcoor] = TriangleRayIntersection(pos,dir, vert1, vert2, vert3,'planeType','one sided');
    xcoor = rmmissing(xcoor);
    if isempty(xcoor) == 0
        xcoor_1(i,:) = xcoor;
        dis_1(i,:)  = dis;
        plot3([trajectory(i,2) xcoor(1)],[trajectory(i,3) xcoor(2)],[trajectory(i,1) xcoor(3)])
        hold on
    end
end
figure(675)

for j = 1:length(xcoor_1)
    plot3([trajectory(j,2) xcoor_1(j,1)],[trajectory(j,3) xcoor_1(j,2)],[trajectory(j,1) xcoor_1(j,3)])
    hold on
end
patch(object)
set(gca,'DataAspectRatio',[.5 .01 50])
view(2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    _____ __  __ __  __     
%   / ____|  \/  |  \/  |    
%  | (___ | \  / | \  / |___ 
%   \___ \| |\/| | |\/| / __|
%   ____) | |  | | |  | \__ \
%  |_____/|_|  |_|_|  |_|___/
% http://patorjk.com/software/taag/#p=display&f=Big&t=SMMs                           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                         

%% TTC - Time To Collision - 
% If there is a ray cast take the distance and the slope(speed) to
% calculate TTC as distance/speed.


%% TLC - Time to Lane Crossing - 
% If there is a ray cast to the lane, prefrom similar calculation as TTC
%% PET - Post Enchroachment Time - 
% 
%% DRAC - Deceleration Rate to Avoid Crash - 
% If there is a ray cast to an entinty, take the current slope, preform
% newtons equation of montion to calculate how much deceleration is needed
% to not crash
%% SD - Speed Disparity - 
% If there is a ray cast take the slope of both objects and then subtract
% eachother to get the SD
%% CSI - Conflict Serverity Index - 
%
%% RLP - Reltive Lane Position - 
% Can be calulated all the time, distance from centerline



