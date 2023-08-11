function [DRAC]=fcn_SafetyMetrics_DRAC( ...
    u, ...
    trajectory,...
    rear_axle,...
    TTC,...
    object,...
    flag_object,...
    varargin...
    )
% fcn_SafetyMetrics_DRAC
% This code will caculate the Deceleration Rate to Avoid Crash of a vehicle
%
% 
%
%
% FORMAT:
%
% function [DRAC]=fcn_SafetyMetrics_DRAC( ...
%     u, ...
%     trajectory,...
%     rear_axle,...
%     TTC,...
%     varargin...
%     )
%
% INPUTS:
%
%     u: a matrix with the unit vectors of the trajectory. [time,x,y]
%     trajectory: [time,x,y,yaw_angle] 4x1 vector
%     rear_axle:a matrix containing the points of where the center of the
%   rear axle is. [x,y,z]
%     TTC: a 1xn matrix contaning TTC data
%     (optional inputs)
%
%
% OUTPUTS:
%
%   DRAC: 1xn matrix contaning deceleration rate to avoid crash data
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
    fig_for_debug = 36363;
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
    narginchk(6,7)
    
end


% Does user want to show the plots?
fig_num = [];
if  7== nargin
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
    % Use the unit vector to determine the direction of the ray 
    dir = [u(i,2),u(i,3),u(i,1)];
    % The orgin of the ray. Middle of the rear axel
    pos = [rear_axle(i,1),rear_axle(i,2),trajectory(i,1)];
    
    %Combine the vertices and the faces for use in the
    %'TriangleRayIntersection' function
    vert1_ob = object.Vertices(object.Faces(:,1),:);
    vert2_ob = object.Vertices(object.Faces(:,2),:);
    vert3_ob = object.Vertices(object.Faces(:,3),:);
    
    %Use 'TriangleRayIntersection' to determine if there is an intersection
    %between the mesh and the ray. 
    [~, ~, ~, ~, xcoor_ob] = TriangleRayIntersection(pos,dir, vert1_ob, vert2_ob, vert3_ob,'planeType','one sided');
    % Delete the rows that don't have any data
    xcoor_ob = rmmissing(xcoor_ob);
    if isempty(xcoor_ob) == 0
        % Collect the points that contain the data
        xcoor_1(i,:) = xcoor_ob;
        %dis_1(i,:)  = dis_ob(find(intersect_ob));
        
        % Plot the data by creating a line from center of rear axel to
        % intersection point
        figure(7182);
        plot3([trajectory(i,2) xcoor_ob(1)],[trajectory(i,3) xcoor_ob(2)],[trajectory(i,1) xcoor_ob(3)])
        hold on
    end
end
%figure(675)


if flag_object
    slope_V = (xcoor_1(:,3)-trajectory(1:length(xcoor_1),1))./(xcoor_1(:,1)-trajectory(1:length(xcoor_1),2));
    DRAC = slope_V./TTC;
    figure(5438)
    plot(DRAC);
    title('DRAC');
    grid on
    xlabel('Time');
    ylabel('DRAC');
end

end
