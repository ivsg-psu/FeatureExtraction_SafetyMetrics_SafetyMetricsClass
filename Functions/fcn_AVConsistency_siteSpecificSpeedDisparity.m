    vehicleID = 'type_AV';
    % Read the CSV file
    data = readtable('AVembedded.csv', 'Delimiter', ';');
    data = fcn_AVConsistency_preProcessData(data);
    % Extract data for all vehicles except the specified vehicleID


