function h_array = fcn_PlotWZ_plotPatches(patchArray,varargin)
% fcn_PlotWZ_plotPatches
% Given an array of patch structures, plots each
%
% FORMAT: 
%
%       h_array = fcn_PlotWZ_plotPatches(patchArray,{fig_num},{indices})
%
% INPUTS:
%
%      patchStruct: a structure containing subfields that have the
%      following fields:
%           patchArray{i_patch}.X
%           patchArray{i_patch}.Y
%      Note that i_patch denotes an array of patch structures. Each 
%      structure will be plotted separately.
%
%      (OPTIONAL INPUTS)
%      fig_num: a figure number to plot into
%      indices: a vector of indices indicating which patch objects to plot
%
% OUTPUTS:
%
%      h_array: a vector of handles to the resulting patch objects plotted
%      in order of the indices (if provided)
%
% DEPENDENCIES:
%
%      ## NOT CURRENTLY USED: fcn_Patch_checkInputsToFunctions
%
% EXAMPLES:
%      
%       See the script: script_test_fcn_PlotWZ_plotPatches.m for a full test
%       suite. 
%
% This function was written by C. Beal
% Questions or comments? cbeal@bucknell.edu 

% Revision history:
%     2022_01_25 C. Beal
%     -- wrote the code
%     2022_08_01 S. Brennan
%     -- fixed bug if figure is empty
%     2022_08_07 S. Brennan
%     -- added edge color definition support
%     2022_08_10 S. Brennan
%     -- renamed function 
%     -- edited to directly use the patch structure format
%     2022_08_11 S. Brennan
%     -- fixed gcf bug
%     -- removed point handles outputs (not used)

flag_do_debug = 0; % Flag to plot the results for debugging
flag_do_plots = 0; % Flag to plot the results at end of script
flag_this_is_a_new_figure = 1; % Flag to check to see if this is a new figure
flag_check_inputs = 1; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1,'STARTING function: %s, in file: %s\n',st(1).name,st(1).file);
end


%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _       
%  |_   _|                 | |      
%    | |  _ __  _ __  _   _| |_ ___ 
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |                  
%              |_| 
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag_check_inputs == 1
    % Are there the right number of inputs?
    if nargin < 1 || nargin > 3
        error('Incorrect number of input arguments')
    end
    
    % Check the data input
    % fcn_Path_checkInputsToFunctions(traversals, 'traversals');

end

% Did the user provide a figure number?
if 2 <= nargin
    temp = varargin{1};
    if ~isempty(temp)
        fig_num = temp;
        figure(fig_num);
        flag_this_is_a_new_figure = 0;
    end
else
    fig = gcf;
    fig_num = fig.Number;
    flag_do_plots = 1;
end


% Did the user provide a specific index vector?
if 3 == nargin    
    idxVec = varargin{2};
else    
    idxVec = (1:length(patchArray))';
end

%% Main body of the code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
figure(fig_num);

% Check to see if hold is already on. If it is not, set a flag to turn it
% off after this function is over so it doesn't affect future plotting
flag_shut_hold_off = 0;
if ~ishold
    flag_shut_hold_off = 1;
    hold on
end

NumPatches = length(idxVec);
h_array = zeros(NumPatches,1);
for ith_patch= 1:NumPatches
    current_patch = patchArray(idxVec(ith_patch));
    if isstruct(current_patch)
        names = fieldnames(current_patch);
        if any(strcmp(names,'Vertices'))
            h_array(ith_patch) = patch(current_patch);
        else
            % Check each branch for a patch type
            names = fieldnames(patchArray);
            Nnames = length(names);
            
            for ith_name = 1:Nnames
                fcn_PlotWZ_plotPatches(patchArray.(names{ith_name}),fig_num);                                
                if contains(names{ith_name},'3D')
                    view([37.5 30]);
                    lighting flat
                    shading flat
                end
            end % Ends for loop through names
        end % Ends if statement for structure check
    end
end



% Shut the hold off?
if flag_shut_hold_off
    hold off;
end

% Add labels? 
if flag_this_is_a_new_figure == 1
    axis equal
    grid on

    xlabel('X [m]')
    ylabel('Y [m]')
end


%% Plot the results (for debugging)?
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
if flag_do_plots
    
    % (nothing to do here - it's a plotting function)        
    
end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function




%% Functions follow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   ______                _   _
%  |  ____|              | | (_)
%  | |__ _   _ _ __   ___| |_ _  ___  _ __  ___
%  |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
%  | |  | |_| | | | | (__| |_| | (_) | | | \__ \
%  |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
%
% See: https://patorjk.com/software/taag/#p=display&f=Big&t=Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%§
