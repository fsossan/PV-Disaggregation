function time_matlab = epochToMatlabTime(epoch_s)
% EPOCHTOMATLABTIME returns matlab time from Unix epoch in seconds.
% Matlab time is the number of days since 0 Jan 0000
% Fabrizio Sossan, DESL EPFL, 2016

offset = datenum('1970', 'yyyy');
time_matlab = offset + epoch_s/8.64e4;
end

