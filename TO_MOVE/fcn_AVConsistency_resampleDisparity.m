function resampled_data = fcn_AVConsistency_resampleDisparity(data,columns_to_resample,query_points)

data = struct2table(data);
    % Initialize a table to store the resampled data
    resampled_data = table();
    vehicle_row = table;
        % Loop over each column to resample
        for col = columns_to_resample
            col_name = col{1};
            % Check if the column exists in the data
            if ismember(col_name, fieldnames(data))
                A = data.snapStation;
                [v, w] = unique( A, 'stable' );
                duplicate_indices = setdiff( 1:numel(A), w );
                data(duplicate_indices,:) =[]; 
                % Perform linear interpolation for the column
                col_filled = data.(col_name);
                %col_filled = fillmissing(col_filled,'nearest');
                col_resampled = interp1(data.snapStation, col_filled, query_points, 'linear');
                col_resampled = fillmissing(col_resampled,'nearest'); 
                if ismember(col_name,{'vehicle_speed','speed_filtered','snapStation'})
                col_resampled(1) = 0;
                end

                % Add the resampled data to the vehicle row
                vehicle_row.(col_name) = col_resampled;
            else
                % If the column doesn't exist, fill with NaNs
                error('wrong column name!');
            end
        end
        
        % Append the vehicle row to the resampled data table
        resampled_data = [resampled_data; vehicle_row];
end
