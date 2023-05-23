function [time,xtotal,ytotal,yaw, flag_object] = fcn_SafetyMetrics_create_vehicleTraj(...
traj_type,...
traj_plot,...
varargin...
)
% fcn_plot_2D_vehicle
% This code will plot a vehicle given the x,y,and angle.
% 
% 
% 
% FORMAT:
% 
% function [xtotal,ytotal] = fcn_SafetyMetrics_create_vehicleTraj( ...
% varargin...
% )
% 
% INPUTS:
%       traj_type: a number 1 - 5 representing which trajectory is wanted
%       traj_plot: a boolean value if simple plotting is wanted. 1 = plot
%    
%
% OUTPUTS:
%  xtotal:1000xn matrix of x coordinates
%  ytotal:1000xn matrix of y coordinates
% 
% 
% DEPENDENCIES:
% 
%     
% 
% 
% EXAMPLES:
% 

% This function was written on 2021_07_11 by Sean Brennan
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
flag_check_inputs = 0; % Set equal to 1 to check the input arguments 
flag_do_plot = 0;      % Set equal to 1 for plotting 
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
    narginchk(3,4)

%     % Check the AABB input, make sure it is '4column_of_numbers' type
%     fcn_MapGen_checkInputsToFunctions(...
%         AABB, '4column_of_numbers',1);
%  
%     % Check the test_points input, make sure it is '2column_of_numbers' type
%     fcn_MapGen_checkInputsToFunctions(...
%         test_points, '2column_of_numbers');
 
end

% Does user want to show the plots?
if  4== nargin
    fig_num = varargin{end};
else
    if flag_do_debug
        fig = figure;
        fig_for_debug = fig.Number;
    end
end

lane_width = 12/3.281; % 12ft to m (12ft from FHWA highway)

%Road trajectory
% traj_type 1 is a lane change of a vehicle.
if 1 == traj_type
    %Specify the x coordinates
    x1 = 1:1:100;
    x2 = 101:1:200;
    
    x3 = 201:1:300;
    
    x4 = 301:1:400;
    x5 = 401:1:500;
    xtotal = [x1,x2,x3,x4,x5];
    %Specify the first y segments
    
   
    
    y1 = zeros(1,100);
    y2 = modify_sigmoid(x2,101,200,0,lane_width,17,1);
    y3 = zeros(1,100)+lane_width;
    y4 = modify_sigmoid(x4,301,400,lane_width,0,17,1);
    y5 = zeros(1,100);
    
    ytotal = [y1,y2,y3,y4,y5];
    
    time = 1:1:500;
    
    % calculate the yaw
    yaw = caculate_yaw(xtotal,ytotal);
    yaw(isnan(yaw)) = 0;
    % flag for objects
    flag_object = 0;
    
    % Plot the modified sigmoid function
    if traj_plot
        plot(xtotal, ytotal);
        axis([-1 xtotal(end) -2*lane_width 2*lane_width]);
        xlabel('x');
        ylabel('y');
        title('Modified Sigmoid Function lane change');
        grid on
    end
end
% traj_type: 2 stopping at a stop sign
% Vehicle will drive 300m and stop at stop sign then continue driving

if 2 == traj_type
    % Set up x coordinates
    x1 = 1:1:300; %driving up to stop sign
    x2 = zeros(1,100)+301;
    x3 = 302:1:401;
    xtotal = [x1,x2,x3];
    % Set up y coordinates
    ytotal = zeros(1,500);
    % Set up the time
    time = 1:1:500;
    %Calculate the Yaw
    yaw = caculate_yaw(xtotal,ytotal);
    yaw(isnan(yaw)) = 0;
    
    %flag for object
    flag_object = 0;
    
    % Plot the trajectory
    if traj_plot
        plot(xtotal, ytotal);
        axis([-1 xtotal(end) -2*lane_width 2*lane_width]);
        xlabel('x');
        ylabel('y');
        title('Stopping at a stop sign');
        grid on
    end
    
end

% traj_type: 3 half-lane change around an object

if 3 == traj_type
    %Specify the x coordinates
    x1 = 1:1:200;
    x2 = 201:1:300;
    x3 = 301:1:500;
    xtotal = [x1,x2,x3];
    %Specify the first y segments
    y1 = zeros(1,200);
    y2 = modify_sigmoid(x2,201,300,0,lane_width,17,1);
    y3 = zeros(1,200)+lane_width;
    ytotal = [y1,y2,y3];
    
    time = 1:1:500;
    
    %caculate the yaw
    yaw = caculate_yaw(xtotal,ytotal);
    yaw(isnan(yaw)) = 0;
    %object flag
    flag_object = 1;
    % Plot the modified sigmoid function
    % Plot the trajectory
    if traj_plot
        plot(xtotal, ytotal);
        axis([-1 xtotal(end) -2*lane_width 2*lane_width]);
        xlabel('x');
        ylabel('y');
        title('Half-lane change with object');
        grid on
    end
end

% traj_type: 4 right hand turn
if 4 == traj_type
    
    % X axis driving
    x1 = 1:1:200;
    y1 = zeros(1,200);
    
    % Making the turn
    r = 10;
    turn_angle = pi/2;
    theta = linspace(0, turn_angle, 100);
    x2 = r*sin(theta)+x1(end);
    y2 = r*cos(theta)-(r-y1(end));
    
    % Y axis driving
    x3 = zeros(1,200)+210;
    y3 = -11:-1:-210;
    
    % Concatenate the segments
    xtotal = [x1,x2,x3];
    ytotal = [y1,y2,y3];
    
    
    %time
    time = 1:1:500;
    
    %Yaw
    yaw = caculate_yaw(xtotal,ytotal);
    yaw(isnan(yaw)) = 0;
    
    %object flag
    flag_object = 0;
    
    % Plot the trajectory
    if traj_plot
        plot(xtotal, ytotal);
        %axis([-1, xtotal(end)+20, 10, ytotal(end)-10]);
        xlabel('x');
        ylabel('y');
        title('Right turn');
        grid on
    end
end

% traj_type: 5 left hand turn
if 5 == traj_type
    
    % X axis driving
    x1 = 1:1:200;
    y1 = zeros(1,200);
    
    % Making the turn
    r = 10;
    turn_angle = (pi())/2;
    theta = linspace(turn_angle,0, 100);
    x2 = r*cos(theta)+x1(end);
    y2 = -r*sin(theta)+(r-y1(end));
    
    % Y axis driving
    x3 = zeros(1,200)+210;
    y3 = 11:1:210;
    
    % Concatenate the segments
    xtotal = [x1,x2,x3];
    ytotal = [y1,y2,y3];
    
    
    %time
    time = 1:1:500;
    
    %Yaw
    yaw = caculate_yaw(xtotal,ytotal);
    yaw(isnan(yaw)) = 0;
    
    %object flag
    flag_object = 0;
    
    % Plot the trajectory
    if traj_plot
        plot(xtotal, ytotal);
        %axis([-1, xtotal(end)+20, 10, ytotal(end)-10]);
        xlabel('x');
        ylabel('y');
        title('Left turn');
        grid on
    end
end


% traj_type:2 constant radius circle.
% if 2 == traj_type
%     r = 250;%radius of 250m
%     
%     th = 0:2*pi/499:2*pi;
%     time = 1:1:500;
%     xtotal = r * cos(th);
%     ytotal = r * sin(th);
%     
%     yaw = caculate_yaw(xtotal,ytotal);
%     yaw(isnan(yaw)) = 0;
%     
%     plot(xtotal, ytotal);
% end


    function y = modify_sigmoid(t, t0, t1, y0, y1, a_factor, b_factor)
        % MODIFY_SIGMOID computes a modified sigmoid function with adjustable parameters
        
        % Compute the adjusted parameters
        a = a_factor / (t1 - t0);
        b = b_factor * (t0 + t1) / 2;
        
        % Compute the modified sigmoid function
        y = y0 + (y1 - y0) ./ (1 + exp(-a * (t - b)));
    end

    function [yaw] = caculate_yaw(x,y)
        %calulate the Yaw angle by taking the current point and the
        %previous point and calculating the atan of that line and the
        %origin
        previous_point_x = x(1);
        previous_point_y = y(1);
        for i = 1:length(x)
            current_point_x = x(i);
            current_point_y = y(i);
            
            slope = (current_point_y - previous_point_y)/(current_point_x - previous_point_x);
            
            yaw(i) = atan(slope);
            
            previous_point_x = x(i);
            previous_point_y = y(i);
            
        end
    end
end