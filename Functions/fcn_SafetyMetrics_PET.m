function [PET]=fcn_SafetyMetrics_PET( ...
    car1_patch, ...
    vehicle_param,...
    varargin...
    )
% fcn_SafetyMetrics_PET
% This code will caculate the Post Enchroachment Time (PET).
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
%   PET: 1xn matrix of the Post-enchroachtment Time.
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
    narginchk(2,3)
    
end


% Does user want to show the plots?
fig_num = [];
if  3== nargin
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
flag_car2 =1;
if flag_car2 == 1
    car2_x =1:1:500;
    car2_y = zeros(1,500)+3.657;
    car2_t = 500:1:999;
    car2_yaw = zeros(1,500)';
    
    car2_traj = [car2_t',flip(car2_x'),car2_y',car2_yaw];
    % Find the unit vector for this second vehicle
    [u2,rear_axle2]=fcn_SafetyMetrics_unit_vector(car2_traj,vehicle_param,36363);
    
    % Go through the same procedure to use 'TriangleRayIntersection'
    for i = 1:length(u2)
        dir = [0,0,-1];
        pos = [rear_axle2(i,1),rear_axle2(i,2),car2_traj(i,1)];
        
        vert1_car1 = car1_patch.Vertices(car1_patch.Faces(:,1),:);
        vert2_car1 = car1_patch.Vertices(car1_patch.Faces(:,2),:);
        vert3_car1 = car1_patch.Vertices(car1_patch.Faces(:,3),:);
        
        [~, ~, ~, ~, xcoor_car1] = TriangleRayIntersection(pos,dir, vert1_car1, vert2_car1, vert3_car1,'planeType','one sided');
        xcoor_car1 = rmmissing(xcoor_car1);
        if isempty(xcoor_car1) == 0
            xcoor_car1_points(i,:) = xcoor_car1;
            %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
        else
            xcoor_car1_points(i,:) = [NaN,NaN,NaN];
        end
    end
    figure(36363)
    for i = 1:length(xcoor_car1_points)
        %if xcoor_car1_points(i,1) ~=0
            plot3([car2_traj(i,2) xcoor_car1_points(i,1)],[car2_traj(i,3) xcoor_car1_points(i,2)],[car2_traj(i,1) xcoor_car1_points(i,3)],'b')
            hold on
        %end
        %     plot3(trajectory(j,2),trajectory(j,3),trajectory(j,1),'ro')
    end
    % Plot first car 3d mesh
    patch(car1_patch)
    set(gca,'DataAspectRatio',[10 1 50])
    view(-40,40);
    % Calculate the PET use the thesis definition proving that PET is just
    % the height between the intersection point and the orgin of the ray
    PET = car2_traj(:,1)- xcoor_car1_points(:,3);
    % Plot PET vs time
    figure(578)
    plot(PET)
    title('PET')
    grid on
    xlabel('Time');
    ylabel('PET');
end

end
