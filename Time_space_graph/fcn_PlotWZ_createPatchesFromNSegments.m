function [S] = ...
    fcn_PlotWZ_createPatchesFromNSegments(layers,varargin)
% function fcn_PlotWZ_createPatchesFromNSegments
% Creates a plottable patch structure given layers of data and color
% settings for each layer. 
% 
% Notes:
% Patches are created linking, in order, vertex data from layer 1 to layer
% 2, then layer 2 to layer 3, etc. The vertex data is assumed to be [x y
% z]. For example, if there are N data arranged as:
% 
% vertex1 ---- vertex2 --- vertex3 ---  ... --- vertex(N-1)--- vertexN
% 
% Then the linking from layer 1 to 2 to 3 (etc) would be:
% 
% (Level 3)
% vertex1 ---- vertex2 --- vertex3 ---  ... --- vertex(N-1)--- vertexN
%   |        /  |          /  |                /  |           /  |
%   |       /   |         /   |               /   |          /   |
% 
% (Level 2)
% vertex1 ---- vertex2 --- vertex3 ---  ... --- vertex(N-1)--- vertexN
%   |        /  |          /  |                /  |           /  |
%   |       /   |         /   |               /   |          /   |
% (Level 1)
% vertex1 ---- vertex2 --- vertex3 ---  ... --- vertex(N-1)--- vertexN
% 
% It uses Newell's method to maintain patch orientation (e.g.
% counter-clockwise when indexing the vertices), to ensure the faces are
% outward facing.
%
% FORMAT:
%
%      S = fcn_PlotWZ_createPatchesFromNSegments(layers,(fig_num))
%
% INPUTS:
%
%      layers: a structure array containing fields of data and color
%
%      (OPTIONAL INPUTS)
%
%      fig_num: a figure number to plot result
%
% OUTPUTS:
%
%      S: a patch-style output structure array 
%
% DEPENDENCIES:
%
%      fcn_DebugTools_checkInputsToFunctions
%      fcn_PlotWZ_initializeColors
%
% EXAMPLES:
%
%      See the script:
%      script_test_fcn_PlotWZ_createPatchesFromNSegments.m for a full
%      test suite.
%
% This function was originally written on 2022_08_09 by Shashank Garikipati

% Revision history:
%      2022_08_09 - S. Brennan, sbrennan@psu.edu
%      -- first write of the code

flag_do_debug = 0; % Flag to plot the results for debugging
flag_check_inputs = 1; % Flag to perform input checking
flag_do_plots = 0; % Flag to perform plotting

if flag_do_debug
    fig_debug = 23455;
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
    if  nargin > 2 || nargin < 1
        error('Incorrect number of input arguments')
    end
    
    % Check the layers input, should be a structure type
    template_structure = struct('data',{},'color',{});
    fcn_DebugTools_checkInputsToFunctions(layers, 'likestructure',template_structure);

    % Check that there are at least 2 layers
    if length(layers)<2 
        error('The layers structure must have at least 2 layers defined. See the example script.');
    end
    
    % Check that all the data points are same length (Npoints) and colors
    % are a 3x1.
    Npoints = length(layers(1).data(:,1));
    for ith_layer = 1:length(layers)
        data = layers(ith_layer).data;
        try
            fcn_DebugTools_checkInputsToFunctions(data,  '2or3column_of_numbers',[Npoints Npoints]);
        catch
            error('The layer(%.0d).data is of different length (length = %.0d) than layer 1 (length = %.0d). All data must be same row length.',ith_layer,length(data(:,1)),Npoints);
        end
        
        color = layers(ith_layer).color;
        try
            fcn_DebugTools_checkInputsToFunctions(color, '3column_of_numbers',[1 1]);
        catch
            error('The layer(%.0d).color is not a 3x1 array',ith_layer);
        end
    end
end

% Does user want to show the plots?
if 2 == nargin
    temp = varargin{end};
    if ~isempty(temp)
        fig_num = temp;
        figure(fig_num);
        flag_do_plots = 1;
    end
else
    if flag_do_debug
        fig = figure;
        fig_num = fig.Number;
        flag_do_plots = 1;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _
%  |  \/  |     (_)
%  | \  / | __ _ _ _ __
%  | |\/| |/ _` | | '_ \
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Fill in the vertices and faces
% - vertices: these are the coordinates of the points
% - faces: these are the indices of the points that create triangles
% If there are 2 vertices per data, there are 4 points total. This can make
% 2 triangles. If there are 3 vertices per data, there are 6 points total.
% This can make 4 triangles. The relationship between triangles (e.g.
% faces) and the vertices is:
Nlayers = length(layers);
Npoints = length(layers(1).data(:,1));
Nfaces_per_layer_pair = 2*(Npoints-1);
Nfaces = Nfaces_per_layer_pair*(Nlayers-1);

% Initialize vertices and vertex colors
vertices = zeros(Npoints*Nlayers,3);
vertex_colors = zeros(length(vertices(:,1)),3); 

% Initialize with first layer data
vertices(1:Npoints,:) = layers(1).data; 
vertex_colors(1:Npoints,:) = repmat(layers(1).color,Npoints,1);

% Loop through layers 2 and upward, filling in data. Note that the faces
% cannot be defined until layer 2 since faces connect layer 1 up to 2.
faces = zeros(Nfaces,3);
for ith_layer = 2:Nlayers
    % Set the data indices we are working on. THese offset indices are the
    % numbers that start each row's worth of data. For example, if there
    % are 3 points in each row, and 4 layers, then the offset for layers 1,
    % 2, 3, and 4 would be 0, 3, 6, and 9. Namely, this is how much to
    % "add" to the indices in order to find the points starting for that
    % layer.
    data_index_lower = ith_layer - 1;
    data_index_upper = ith_layer;    
    offset_data_index_lower = (data_index_lower-1)*Npoints;
    offset_data_index_upper = (data_index_upper-1)*Npoints;
    
    % Fill in the vertices and vertex colors for current layer
    vertices(offset_data_index_upper+1:offset_data_index_upper+Npoints,:) = layers(ith_layer).data;
    vertex_colors(offset_data_index_upper+1:offset_data_index_upper+Npoints,:) = repmat(layers(ith_layer).color,Npoints,1);
    
    
    for ith_station = 2:Npoints
        % Fill in rows we are updating
        current_vertex_lower = offset_data_index_lower + ith_station;
        current_vertex_upper = offset_data_index_upper + ith_station;
        
        % Fill in the first triplicate
        current_face_row = Nfaces_per_layer_pair*(ith_layer-2) + (ith_station - 2)*2 + 1;
        faces(current_face_row,:) = [current_vertex_lower-1 current_vertex_upper current_vertex_upper-1];
        
        % Fill in second triplicate
        current_face_row = Nfaces_per_layer_pair*(ith_layer-2) + (ith_station - 2)*2 + 2;
        faces(current_face_row,:) = [current_vertex_lower-1 current_vertex_lower current_vertex_upper];
        
    end
end


clear S
S.Vertices = vertices;
S.Faces = faces;
S.FaceVertexCData = vertex_colors;
S.FaceColor = 'flat'; % 'none' or 'flat';
S.EdgeColor = 'flat';
S.LineWidth = 2;


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
    
    % plot the final XY result
    figure(fig_num);
    hold on;
    grid on
    axis equal
         
    patch(S);
    view([37.5 30]);
    lighting flat
    shading faceted
            
end

if flag_do_debug
    fprintf(1,'ENDING function: %s, in file: %s\n\n',st(1).name,st(1).file);
end

end % Ends main function



