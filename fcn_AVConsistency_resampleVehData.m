function resampled_data = fcn_AVConsistency_resampleVehData(data,columns_to_resample,query_points)


    % Get unique vehicle IDs
    vehicle_ids = unique(data.vehicle_id);   

    
    % List of columns to resample, add or remove column names as necessary
    % columns_to_resample = {'vehicle_speed', 'speed_filtered', 'snapStation', 'vehicle_x', 'vehicle_y', ...
    %                        'vehicle_x_filtered', 'vehicle_y_filtered'};
    
    % Initialize a table to store the resampled data
    resampled_data = table();

    % Loop over each vehicle ID to resample its data
    for i = 1:length(vehicle_ids)
        % Extract data for the current vehicle ID
        vehicle_data = data(strcmp(data.vehicle_id, vehicle_ids{i}), :);
        
        % Initialize a row for this vehicle_id
        vehicle_row = table(vehicle_ids(i), 'VariableNames', {'vehicle_id'});

        % Loop over each column to resample
        for col = columns_to_resample
            col_name = col{1};
            % Check if the column exists in the data
            if ismember(col_name, data.Properties.VariableNames)
                A = vehicle_data.snapStation;
                [v, w] = unique( A, 'stable' );
                duplicate_indices = setdiff( 1:numel(A), w );
                vehicle_data(duplicate_indices,:) =[]; 
                % Perform linear interpolation for the column
                %col_filled = fillmissing(vehicle_data.(col_name),'nearest',2);
                
                col_resampled = interp1(vehicle_data.snapStation, vehicle_data.(col_name), query_points, 'linear','extrap');
                if ismember(col_name,{'vehicle_speed','speed_filtered'})
                col_resampled(1) = 0;
                end

                % Add the resampled data to the vehicle row
                vehicle_row.(col_name) = col_resampled;
            else
                % If the column doesn't exist, fill with NaNs
                error('wrong colume name!');
            end
        end
        
        % Append the vehicle row to the resampled data table
        resampled_data = [resampled_data; vehicle_row];
    end
end
