function data = fcn_AVConsistency_preProcessData(data, pathXY)
% fcn_AVConsistency_preProcessData.m
% This function prepares the raw data from SUMO simulation for use.
% Specifically, it performs the following tasks:
% 1. Adds the distance traveled for each vehicle
% 2. Snaps the vehicle's station to the centerline
%
% FORMAT:
%
%       data = fcn_AVConsistency_preProcessData(data, pathXY)
%
% INPUTS:
%       data: Raw simulation data from SUMO, usually in table format.
%       pathXY: Coordinates of the centerline or path for snapping.
%
% OUTPUTS:
%       data: Processed data with added distance traveled and snapped station.
%
% DEPENDENCIES:
%       - fcn_AVConsistency_addDisTravel
%       - fcn_AVConsistency_addSnapStation
%
% EXAMPLES:
%
%       See script_AVConsistency_Demo.m for a full test suite. 
%
% This function was written by Wushuang
% Questions or comments? Contact 2023 08 22
%
% REVISION HISTORY:
%
% 2023 08 22: Initial creation of the script.
% 2023 08 22: Updated to add detailed comments.
%
% TO DO:
%
% -- Further refinements or functionality as required.
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
    if nargin ~= 2
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

% Add the distance traveled for each vehicle
data = fcn_AVConsistency_addDisTravel(data);

% Snap the vehicle's station to the centerline
data = fcn_AVConsistency_addSnapStation(data,pathXY); 

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
