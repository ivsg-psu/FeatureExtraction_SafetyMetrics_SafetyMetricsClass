function fcn_SafetyMetrics_plot_3D_vehicle( ...
    vehicle_position, ...
    vehicle_param, ...
    varargin...
    )
% fcn_plot_3D_vehicle
% This code will plot a vehicle given the x,y,t and angle.
%
%
%
% FORMAT:
%
% function fcn_SafetyMetrics_plot_3D_vehicle( ...
%     vehicle_position, ...
%     vehicle_param, ...
%     (plot_style), ...
%     (fig_num)
%     )
%
% INPUTS:
%
%     vehicle_position: [time,x,y,yaw_angle] 4x1 vector
%
%     vehicle_param: sturcture containing
%       a: distnace from origin to front axel (positive)
%       b: distnace form origin to rear axel (positive)
%       Lf:Length from origin to front bumper
%       Lr:Length from origin to rear bumper
%       w_tire_tire: width from center of tire to center of tire
%       w_vehicle:width form outer most left side to outer most right side
%       tire_width: width of one tire
%       tire_length: diameter of one tire
%
%
%     (optional inputs)
%     plot_style: matlab input plotting style such as 'b-'
%
%     fig_num: any number that acts somewhat like a figure number output.
%     If given, this forces the variable types to be displayed as output
%     and as well makes the input check process verbose.
%
%
% OUTPUTS:
%
%
%
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
% 2023_05_17 by Marcus Putz and Sean Brennan
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
    fig_for_debug = 225;
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
    narginchk(2,4)
    
    %     % Check the AABB input, make sure it is '4column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         AABB, '4column_of_numbers',1);
    %
    %     % Check the test_points input, make sure it is '2column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         test_points, '2column_of_numbers');
    
end

% Does user want to specify the plot style?
plot_style = '-'; % Default is a line - changes color each time plot is called
if  3<= nargin
    temp = varargin{1};
    if ~isempty(temp)
        plot_style = temp;
    end
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

%% open figures
if isempty(fig_num)
    figure; % create new figure with next default index
else
    % check to see that the handle is an axis. If so, use it and don't just
    % go to a new figure
    if isgraphics(fig_num,'axes')
        axes(fig_num);
    else
        figure(fig_num); % open specific figure
    end
end
hold on % allow multiple plot calls

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

% Calculate the rectangle vertices
vertices = [
    -(vehicle_param.w_vehicle/2), -vehicle_param.Lr,vehicle_position(1,1); %bottom left
    (vehicle_param.w_vehicle/2), -vehicle_param.Lr,vehicle_position(1,1); %top left
    (vehicle_param.w_vehicle/2), vehicle_param.Lf,vehicle_position(1,1); %top right
    -(vehicle_param.w_vehicle/2), vehicle_param.Lf,vehicle_position(1,1); %bottom right
    -(vehicle_param.w_vehicle/2), -vehicle_param.Lr,vehicle_position(1,1)%bottom left
    ];

% Connect the vertices to form the rectangle edges
edges = [
    1, 2;
    2, 3;
    3, 4;
    4, 5;
    5, 1;
    ];


theta = vehicle_position(1,4);


% Create the rotation matrix
R = [cos(theta) -sin(theta),0; sin(theta) cos(theta),0;0,0,1];

% Rotate the translated rectangle
rotated_translated_rect = (R * vertices')';

% Translate the rotated rectangle to current location
rotated_rect = rotated_translated_rect + [vehicle_position(1,2) vehicle_position(1,3) 0];

plot3(rotated_rect(edges(:,1), 1), rotated_rect(edges(:,1), 2),rotated_rect(edges(:,1), 3), plot_style, 'LineWidth', 2);
%plot3(rotated_rect(edges(:,2),1), rotated_rect(edges(:,2),2), rotated_rect(edges(:,2),3), 'r', 'LineWidth', 2);
%§
end
