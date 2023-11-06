function output = fcn_AVConsistency_statistics(data)

meanData = mean(data,"omitnan");
SD = std(data,"omitnan");
upperBD = meanData + 2*SD;
lowerBD = meanData - 2*SD; 
output.meanData = meanData;
output.upperBD = upperBD;
output.lowerBD = lowerBD;
output.SD = SD;
end