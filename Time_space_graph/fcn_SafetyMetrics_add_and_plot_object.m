function fcn_SafetyMetrics_add_and_plot_object( ...
time,...
object_position, ...
object_type,...
varargin...
)
% fcn_plot_add_and_plot_object
% This code will plot an object at the position given.
% 
% 
% 
% FORMAT:
% 
% function fcn_SafetyMetrics_add_and_plot_object( ...
% time,...
% object_position, ...
% (fig_num)
% )
% 
% INPUTS:
%   
%     time: a 1xn matrix of all the times.
%
%     object_position: Position of the object a 2x1 matrix of x and y
%     coordinates
%
%     object_type: a number 1-2 representing what type of object plotting
%     is wanted.
%     1: a circle plotted at each time step 
%     2: a cylindar with a radius specified by FWHA and height equal to
%     time lenght
%
%     (optional inputs)
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
% This function was written on 2023_05_22 by Marcus Putz
% Questions or comments? contact sbrennan@psu.edu

% 
% REVISION HISTORY:
% 
% 2023_05_22 by Marcus Putz and Sean Brennan
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
    narginchk(3,4)
 
end

% Does user want to show the plots?
if  1== nargin
    fig_num = varargin{end};
else
    if flag_do_debug
        fig = figure;
        fig_for_debug = fig.Number;
    end
end

%% open figures
% if isempty(fig_num)
%     fig = figure; % create new figure with next default index
% else
%     % check to see that the handle is an axis. If so, use it and don't just
%     % go to a new figure
%     if isgraphics(fig_num,'axes')
%         axes(fig_num);
%     else
%         fig = figure(fig_num); % open specific figure
%     end
% end
%hold on % allow multiple plot calls

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
%% Generating the object
if 1 == object_type
    % x  and y position / centroid
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
    
    for i = 1:length(time)
        z = zeros(1,length(x2))+time(1,i);
        plot3(x2,y2,z,'color',[0.8500 0.3250 0.0980],'LineWidth', 2);
    end
end

if 2 == object_type
    % the example shown will be a barrel using dimesions from FHWA.
    % DIA = 23"
    dia = 23/39.37; %[m];
    r = dia/2;
    
    %Cylinder 
    [x,y,z] = cylinder(r);
    
        % x  and y position / centroid
    x = object_position(1,1)+x;
    y = object_position(1,2)+y;
    
    %calulate the height
    z = time(end)*z;
    
    %plot everything
    surf(x,y,z);
end

%§
end
