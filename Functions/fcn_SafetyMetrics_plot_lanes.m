function [lane3]=fcn_SafetyMetrics_plot_lanes(...
    lanes,...
    varargin...
    )
% fcn_SafetyMetrics_plot_lanes
% Plotting the lanes of the trajectory 
%
%
%
% FORMAT:
%
% function fcn_SafetyMetrics_plot_lanes(...
%     lanes,...
%     varargin...
%     )
%
% INPUTS:
%
%     lanes: [x,y,x1,y1,...,xn,yn] nxm matrix 
%
%
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
%fcn_PlotWZ_createPatchesFromNSegments
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
% 2023_06_07 by Marcus Putz and Sean Brennan
% -- first write of function
%
% TO DO:
%
% -- fill in to-do items here.

%% Debugging and Input checks
flag_check_inputs = 1; % Set equal to 1 to check the input arguments
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
    narginchk(1,2)
    
    %     % Check the AABB input, make sure it is '4column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         AABB, '4column_of_numbers',1);
    %
    %     % Check the test_points input, make sure it is '2column_of_numbers' type
    %     fcn_MapGen_checkInputsToFunctions(...
    %         test_points, '2column_of_numbers');
    
end

% Does user want to show the plots?
if  2== nargin
    fig_num = varargin{end}; %#ok<NASGU>
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

%First make the lane a lane marker.
% Basically lanes is just the mid-point of the lane. So, to make the
% markings, transpose the lane a distance above and below then connect the
% ends to make a solid polygon. 
width_of_marker = .1524;%[m];
lanes = cell2mat(lanes);
%offset the lanes up a half of marker
top_marker = downsample(lanes + [0 width_of_marker/2],20);
bottom_marker = downsample(lanes - [0 width_of_marker/2],20);

%connecting the top to the bottom
lane_marker = [top_marker;flip(bottom_marker)];
lane_marker3 = [lane_marker,zeros(length(lane_marker),1)];

z_height = zeros(length(lane_marker),1)+length(lanes);
top_lane_marker = [lane_marker,z_height];

color_layer = [255 0 0]/255;
layers(1).data = lane_marker3;
 layers(1).color = color_layer;
layers(2).data = top_lane_marker;
 layers(2).color = color_layer;

lane3=fcn_PlotWZ_createPatchesFromNSegments(layers)
lane3.FaceAlpha = 0.1;
lane3.LineWidth = 0.001;
fcn_PlotWZ_plotPatches(lane3,fig_num)
%patch(lane3);
end

