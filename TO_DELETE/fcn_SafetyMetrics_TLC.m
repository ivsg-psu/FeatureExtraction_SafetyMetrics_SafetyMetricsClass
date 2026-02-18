function [TLC1,TLC2] = fcn_SafetyMetrics_TLC(u, trajectory, rear_axle, lane_patches, varargin)
% fcn_SafetyMetrics_TLC
% This code will caculate the Time To Lane Crossing (TLC) for the lanes.
%
%
% FORMAT:
%
% function [u,rear_axle]=fcn_SafetyMetrics_unit_vector( ...
%     trajectory, ...
%     vehicle_param,...
%     varargin...
%     )
%
% INPUTS:
%
%     u: a matrix with the unit vectors of the trajectory. [time,x,y]
%     trajectory: [time,x,y,yaw_angle] 4x1 vector
%     rear_axle:a matrix containing the points of where the center of the
%   rear axle is. [x,y,z]
%     lane_patches : 1xn struct contaning data for lanes: Vertices, Faces,
% FaceVertexCData, FaceColor, EdgeColor, LineWidth, FaceAlpha
%     (optional inputs)
%
%
% OUTPUTS:
%
%  TLC1: 1xn matrix of the time to lane crossing for a specfic lane.
%  TLC2: 1xn matrix of the time to lane crossing for a specfic lane.
%
%
% DEPENDENCIES:
%
%
% TriangleRayIntersection.m
%
%
% This function was written on 2023_08_10 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_08_10 by Marcus Putz
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
    narginchk(4,5)
    
end


% Does user want to show the plots?
fig_num = [];
if  6== nargin
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
for i = 1:length(u)
    dir = [u(i,2),u(i,3),u(i,1)];
    pos = [rear_axle(i,1),rear_axle(i,2),trajectory(i,1)];
    
    for i_1  = 1:length(lane_patches)
        vert1_lane = lane_patches(i_1).Vertices(lane_patches(i_1).Faces(:,1),:);
        vert2_lane = lane_patches(i_1).Vertices(lane_patches(i_1).Faces(:,2),:);
        vert3_lane = lane_patches(i_1).Vertices(lane_patches(i_1).Faces(:,3),:);
        
        
        [~, ~, ~, ~, xcoor_lane] = TriangleRayIntersection(pos,dir, vert1_lane, vert2_lane, vert3_lane,'planeType','one sided');
        xcoor_lane = rmmissing(xcoor_lane);
        % If there is data in the Xcoor_lane save it, if not save NaN.
        if isempty(xcoor_lane) == 0
            xcoor_lane1{i_1,:}(i,:) = xcoor_lane;
            %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
        else
            xcoor_lane1{i_1,1}(i,:) = [NaN,NaN,NaN];
        end
    end
end
% Plotting the TLC rays and calculating it. 
flag_plot_lane_intersect = 1;
if flag_plot_lane_intersect == 1
    for i = 1:length(u)
        figure(485)
        % The following if statments make sure to only use the rays that
        % make sense for each lane. (The 'TriangleRayIntersection' shoots
        % rays off and will continue returning intersections for all lanes
        % even if the lane is on the other side of another lane.)
        if xcoor_lane1{1,1}(i,1) ~= 0 && trajectory(i,3) > 1.9
            plot3([trajectory(i,2) xcoor_lane1{1,1}(i,1)],[trajectory(i,3) xcoor_lane1{1,1}(i,2)],[trajectory(i,1) xcoor_lane1{1,1}(i,3)],'b')
            hold on
            TLC2(i) = xcoor_lane1{1,1}(i,3) - trajectory(i,1); 
        end
        if xcoor_lane1{2,1}(i,1) ~= 0
            plot3([trajectory(i,2) xcoor_lane1{2,1}(i,1)],[trajectory(i,3) xcoor_lane1{2,1}(i,2)],[trajectory(i,1) xcoor_lane1{2,1}(i,3)],'g')
            hold on
            TLC1(i) = xcoor_lane1{2,1}(i,3) - trajectory(i,1); 
        end
    end
end
% Plot the TLC vs time.
figure(848)
plot(TLC1)
title('TLC of the middle lane');
grid on
xlabel('Time');
ylabel('TLC');

figure(936)
plot(TLC2)
title('TLC of the outside lane');
grid on
xlabel('Time');
ylabel('TLC');


end
