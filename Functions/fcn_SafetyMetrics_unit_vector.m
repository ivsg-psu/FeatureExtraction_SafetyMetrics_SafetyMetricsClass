function [u,rear_axle]=fcn_SafetyMetrics_unit_vector( ...
    trajectory, ...
    vehicle_param,...
    varargin...
    )
% fcn_SafetyMetrics_unit_vector
% This code will caculate the unit vector of the the vehicle along a
% trajectory in space time.
%
% 
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
%     trajectory: [time,x,y,yaw_angle] 4x1 vector
%
%     (optional inputs)
%
%
% OUTPUTS:
%
%   u: a matrix with the unit vectors of the trajectory. [time,x,y]
%   rear_axle: a matrix containing the points of where the center of the
%   rear axle is. [x,y,z];
%
% DEPENDENCIES:
%
%
%
%
% EXAMPLES:
%
% See the script: script_test_fcn_plot_traj_custom_time_interval
% for a full test suite.
%
% This function was written on 2023_05_19 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

%
% REVISION HISTORY:
%
% 2023_05_25 by Marcus Putz
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
    narginchk(2,3)
    
    %     % Check the AABB input, make sure it is '4column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         AABB, '4column_of_numbers',1);
    %
    %     % Check the test_points input, make sure it is '2column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         test_points, '2column_of_numbers');
    
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
% 
% %% open figures
% if isempty(fig_num)
%     figure; % create new figure with next default index
% else
%     % check to see that the handle is an axis. If so, use it and don't just
%     % go to a new figure
%     if isgraphics(fig_num,'axes')
%         axes(fig_num);
%     else
%         figure(fig_num); % open specific figure
%     end
% end
% hold on % allow multiple plot calls

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

change_in_trajectory = diff(trajectory,1,1);

% Fill in the first row by repeating it, so that the length of change in
% trajectory is the same as the number of points in the trajectory data
change_in_trajectory = [change_in_trajectory(1,:); change_in_trajectory];

% Convert each of the changes into unit vectors
mags = sum(change_in_trajectory(:,1:3).^2,2).^0.5;

% Create unit vectors
unit_vector_changes = change_in_trajectory(:,1:3)./mags;

u = unit_vector_changes;

%Calculate the rear axle point
for i = 1:length(trajectory)
theta = trajectory(i,4);


% Create the rotation matrix
R = [cos(theta) -sin(theta); sin(theta) cos(theta)];
rear_axle(i,:) = [trajectory(i,2) trajectory(i,3)] -[vehicle_param.b 0]*R';
end
% The above code does EXACTLY the same as the following, but avoids the
% for-loop (which is slow)
%
% previous_t = 0;
% previous_x = 0;
% previous_y = 0;
% 
% % First get the previous point 
% for i = 1:length(trajectory)
%     current_t = trajectory(i,1);
%     current_x = trajectory(i,2);
%     current_y = trajectory(i,3);
%     
%     %Calculate the vector between current and previous points
%     v_t = current_t - previous_t;
%     v_x = current_x - previous_x;
%     v_y = current_y - previous_y;
%     
%     %Take that vector and divide by magnitude to get unit.
%     mag_v = sqrt((v_t).^2+(v_x).^2+(v_y).^2);
%     
%     u(i,:) = [v_t/mag_v, v_x/mag_v, v_y/mag_v];
%     
%     previous_t = trajectory(i,1);
%     previous_x = trajectory(i,2);
%     previous_y = trajectory(i,3);
%     
% end
%§

figure(fig_num);
clf;
hold on;
grid on;

N_points = length(trajectory(:,1));
rowrange = round(linspace(1,N_points,100)');
min_value = ones(length(rowrange),1);
max_value = min_value*N_points;
rowrange = min([rowrange max_value],[],2);
rowrange = max([rowrange min_value],[],2);

quiver3(trajectory(rowrange,2),trajectory(rowrange,3),trajectory(rowrange,1),u(rowrange,2),u(rowrange,3),u(rowrange,1),0.10);
view(-40,40);
set(gca,'DataAspectRatio',[10 1 50])
title('Unit vector plot');
xlabel('X Axis');
ylabel('Y Axis');
zlabel('Time');


end
