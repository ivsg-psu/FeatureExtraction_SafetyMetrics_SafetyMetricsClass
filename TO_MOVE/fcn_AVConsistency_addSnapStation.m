function newData = fcn_AVConsistency_addSnapStation(data, pathXY)
% fcn_AVConsistency_addSnapStation.m
% This function snaps the vehicle's station to the centerline of the road,
% ensuring that vehicle positions are comparable to each other based on the
% centerline station, and add the snaped station as a new column
%
% FORMAT:
%
%       newData = fcn_AVConsistency_addSnapStation(data, pathXY)
%
% INPUTS:
%       data: The input data containing vehicle positions (usually in table format).
%       pathXY: The path or road centerline data in XY coordinates.
%
% OUTPUTS:
%       newData: The modified data with an added snapStation column indicating the 
%                snapped station of each vehicle on the centerline.
%
% DEPENDENCIES:
%       fcn_Path_snapPointOntoNearestPath: This function is used to snap a point 
%                                          onto the nearest path.
%
% EXAMPLES:
%
%       See script_AVConsistency_Demo.m for a full test suite. 
% This function was written by Wushuang
% Questions or comments? Contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 08 21: Initial creation of the function.
% 2023 08 22: added comments.
% TO DO:
%
% -- Add any future improvements or changes here.

flag_do_debug = 1; % Flag to show function info in UI
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%% check input arguments
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

if flag_check_inputs == 1
    % Are there the right number of inputs?
    if nargin < 2 || nargin > 3
        error('Incorrect number of input arguments')
    end
end


%% Main code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    


    % Iterate through each row of the data to process each vehicle's position
    for ii = 1:height(data)
        % Extract the current vehicle's X and Y position
        point = [data.vehicle_x(ii), data.vehicle_y(ii)];

        % Define the snap type (1 indicates a specific type of snapping, 
        % you can provide more details if necessary)
        flag_snap_type = 1;

        % Snap the current vehicle's position onto the nearest path using the 
        % fcn_Path_snapPointOntoNearestPath function
        [closest_path_point, s_coordinate, first_path_point_index, second_path_point_index, ...
            percent_along_length, distance_real, distance_imaginary] = ...
            fcn_Path_snapPointOntoNearestPath(point, pathXY, flag_snap_type);

        % Store the snapped station value into the data table
        data.snapStation(ii) = s_coordinate;
    end

    % Return the modified data with the added snapStation column
    newData = data;
%% Any debugging?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NA.
end
