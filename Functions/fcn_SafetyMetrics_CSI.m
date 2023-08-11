function [CSI]=fcn_SafetyMetrics_CSI( ...
    car1_patch, ...
    TA,...
    slope_V_car3,...
    rear_axle3,...
    u3,...
    car3_traj,...
    varargin...
    )
% fcn_SafetyMetrics_CSI
% This code will caculate the Conflict Serverity Index (CSI).
%
% 
%
%
% FORMAT:
%
% function [CSI]=fcn_SafetyMetrics_CSI( ...
%     car1_patch, ...
%     TA,...
%     slope_V_car3,...
%     rear_axle3,...
%     varargin...
%     )
%
% INPUTS:
%
%    car1_patch: 1x1 stuct contaning the Vertices, Faces, FaceVertexCData,
%    FaceColor, EdgeColor, and LineWidth of the previosu vehicle.
%    
%    TA: 
%
%
% OUTPUTS:
%
%   CSI: 1xn matrix of the Conflict Severity Index.
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

% Using the SD information, the TA(time to accident) and CS(conflict speed)
% calulate the CSI. 
% CSI = TA/CS
CS = slope_V_car3.*3.6;

CSI =TA'./slope_V_car3
figure(908)
plot(TA',CS);
title('CSI');
grid on
xlabel('TA');
ylabel('CS');

% Version II

for i = 1:length(u3)
    dir = [0,0,-1];
    pos = [rear_axle3(i,1),rear_axle3(i,2),car3_traj(i,1)];
    
    vert1_car1 = car1_patch.Vertices(car1_patch.Faces(:,1),:);
    vert2_car1 = car1_patch.Vertices(car1_patch.Faces(:,2),:);
    vert3_car1 = car1_patch.Vertices(car1_patch.Faces(:,3),:);
    
    [~, ~, ~, ~, xcoor_car1_3] = TriangleRayIntersection(pos,dir, vert1_car1, vert2_car1, vert3_car1,'planeType','one sided');
    xcoor_car1_3 = rmmissing(xcoor_car1_3);
    if isempty(xcoor_car1_3) == 0
        xcoor_car1_3_points(i,:) = xcoor_car1_3;
        %dis_lane1{i_1,:}(i,:)  = dis_lane(find(intersect_lane));
    else
        xcoor_car1_3_points(i,:) = [NaN,NaN,NaN];
    end
end

    figure(687)
    for i = 1:length(xcoor_car1_3_points)
        %if xcoor_car1_points(i,1) ~=0
            plot3([car3_traj(i,2) xcoor_car1_3_points(i,1)],[car3_traj(i,3) xcoor_car1_3_points(i,2)],[car3_traj(i,1) xcoor_car1_3_points(i,3)],'b')
            hold on
        %end
        %     plot3(trajectory(j,2),trajectory(j,3),trajectory(j,1),'ro')
    end

end
