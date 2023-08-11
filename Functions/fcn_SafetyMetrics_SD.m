function [SD,TA,slope_V_car3,rear_axle3,u3,car3_traj]=fcn_SafetyMetrics_SD( ...
    car1_patch, ...
    vehicle_param,...
    trajectory,...
    varargin...
    )
% fcn_SafetyMetrics_SD
% This code will caculate the Speed Disparity (SD).
%
% 
%
%
% FORMAT:
%
% function [PET]=fcn_SafetyMetrics_PET( ...
%     car1_patch, ...
%     vehicle_param,...
%     varargin...
%     )
%
% INPUTS:
%
%    car1_patch: 1x1 stuct contaning the Vertices, Faces, FaceVertexCData,
%    FaceColor, EdgeColor, and LineWidth of the previosu vehicle.
%    vehicle_param: sturcture containing
%       a: distance from origin to front axle (positive)
%       b: distance from origin to rear axle (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outermost left side to outermost right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
%
%
% OUTPUTS:
%
%   SD: nx1 matrix of the Speed Disparity.
%   TA: Time to accident
%   slope_V_car3: speed of the current vehicle
%   rear_axle3: 2xn matrix of the center of rear axel position
%
% DEPENDENCIES:
%
%
% TriangleRayIntersection.m
% fcn_SafetyMetrics_unit_vector
%
% This function was written on 2023_08_11 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_08_11 by Marcus Putz
% -- first write of function
%
% TO DO:
%
% -- fill in to-do items here.

%% Debugging and Input checks
flag_check_inputs = 1; % Set equal to 1 to check the input arguments
%flag_do_plot = 0;      % Set equal to 1 for plotting
flag_do_debug = 0;     % Set equal to 1 for debugging

if flag_do_debug
    fig_for_debug = 1561;
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end

%% check input arguments?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if 1 == flag_check_inputs
    
    % Are there the right number of inputs?
    narginchk(3,4)
    
end


% Does user want to show the plots?
fig_num = [];
if  4== nargin
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
    end
else
    if flag_do_debug
        fig = figure;
        fig_for_debug = fig.Number;
    end
end

%% Start of main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%See: http://patorjk.com/software/taag/#p=display&f=Big&t=Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§
%First create a car that is slightly behind the main one, but it is going
%faster. 
car3_x =1:1:500;
car3_y = zeros(1,500);
car3_t = linspace(50,425,500);
car3_yaw = zeros(1,500)';

car3_traj = [car3_t',car3_x',car3_y',car3_yaw];

[u3,rear_axle3]=fcn_SafetyMetrics_unit_vector(car3_traj,vehicle_param,687);

% Using procedure as other SSMs to carry out ray casting
for i = 1:length(u3)
    dir = [u3(i,2),u3(i,3),u3(i,1)];
    pos = [rear_axle3(i,1),rear_axle3(i,2),car3_traj(i,1)];
    
    vert1_car1 = car1_patch.Vertices(car1_patch.Faces(:,1),:);
    vert2_car1 = car1_patch.Vertices(car1_patch.Faces(:,2),:);
    vert3_car1 = car1_patch.Vertices(car1_patch.Faces(:,3),:);
    
    [~, ~, ~, ~, xcoor_car1_2] = TriangleRayIntersection(pos,dir, vert1_car1, vert2_car1, vert3_car1,'planeType','one sided');
    xcoor_car1_2 = rmmissing(xcoor_car1_2);
    if isempty(xcoor_car1_2) == 0
        xcoor_car1_2_points(i,:) = xcoor_car1_2;
        %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
    else
        xcoor_car1_2_points(i,:) = [NaN,NaN,NaN];
    end
end

  for i = 1:length(xcoor_car1_2_points)
        %if xcoor_car1_points(i,1) ~=0
        figure(687)
            plot3([car3_traj(i,2) xcoor_car1_2_points(i,1)],[car3_traj(i,3) xcoor_car1_2_points(i,2)],[car3_traj(i,1) xcoor_car1_2_points(i,3)],'b')
            hold on
         TA(i) = xcoor_car1_2_points(i,3) - car3_traj(i,1);
        %     plot3(trajectory(j,2),trajectory(j,3),trajectory(j,1),'ro')
  end

figure(687)
patch(car1_patch)
set(gca,'DataAspectRatio',[10 1 50])
view(-40,40);
hold on

%Calculating the velocity of the vehicles by calculating the slope. current
%point and previous point.
slope_V_car3 = (xcoor_car1_2_points(:,3)-car3_traj(1:length(xcoor_car1_2_points),1))./(xcoor_car1_2_points(:,1)-car3_traj(1:length(xcoor_car1_2_points),2));
slope_V = (-trajectory(1,1)+trajectory(end,1))/(-trajectory(1,2)+trajectory(end,2));

SD = slope_V_car3.^-1 - slope_V.^-1;
% plot3(car3_traj(:,2),car3_traj(:,3),car3_traj(:,1));
% grid on

end
