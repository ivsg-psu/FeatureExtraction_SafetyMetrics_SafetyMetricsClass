% fcn_AVConsistency_addSnapStation
% This function snaps the vehicle's station to the centerline of the road,
% ensuring that vehicle positions are comparable to each other based on the
% centerline station.
%
% FORMAT:
%
%       newData = fcn_AVConsistency_addSnapStation(data, pathXY)
%
% INPUTS:
%
%       data: The input data containing vehicle positions (usually in table format).
%       pathXY: The path or road centerline data in XY coordinates.
%
% OUTPUTS:
%
%       newData: The modified data with added snapStation column indicating the 
%                snapped station of each vehicle on the centerline.
%
% DEPENDENCIES:
%       fcn_Path_snapPointOntoNearestPath: This function is used to snap a point 
%                                          onto the nearest path.
%
% EXAMPLES:
%
%       % To use this function, provide the vehicle data and path data:
%       modifiedData = fcn_AVConsistency_addSnapStation(vehicleData, roadCenterline);
%
% This function was written by Wushuang
% Questions or comments? contact wxb41@psu.edu
%
% REVISION HISTORY:
%
% 2023 08 21 - Initial creation of the function.
% TO DO:
%
% -- Add any future improvements or changes here.

function newData = fcn_AVConsistency_addSnapStation(data, pathXY)

    % Loop through each row of the data to process each vehicle's position
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

    % Return the modified data
    newData = data;
end
