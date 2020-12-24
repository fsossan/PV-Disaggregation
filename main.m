clc;
clear all;
close all;

% Load libraries: pvlib, sheremesh, and some personal functions
addpath(genpath('./lib/'));

location.UTC = 0;
location.latitude = 46.518374;
location.longitude = 6.565068;
location.altitude = 394;

data = csvread('./data/data.csv', 1, 0);
ts = datenum(data(:, 1:6));
data = [ts, data(:, 7:end)];
data_orig = data;

%data = [ts, GHI, P, (1:numel(ts))'];


% Remove from data large zenith angle, select a smaller period, a remove
% NaNs
[~, zenith] = POAirradiance(ts*0, ts, location, 0, 0);
large_zenith = zenith > 75;

data(large_zenith, :) = [];
data = data(1e4:2e4, :);
sel = any(isnan(data), 2);
data(sel, :) = [];

% Calculate and show irradiance proxies
proxies = POA_proxies(data(:,3), data(:,1), location);      
M = proxies(:,:);
plot(M);

[alpha, estimated_demand] = methodC(M, data(:,2), 5);

% --
% Show the results of the process for the training period
% --
estimated_PV = M/1000 * alpha;

plot(data(:, 2), 'linewidth', 2)
hold on
plot(estimated_PV)
plot(estimated_demand)
plot(estimated_demand - estimated_PV)
hold off
xlabel('Samples'); ylabel('Active Power');

legend('Aggregated (Measured)', ...
'PV (estimated)', ...
'Load (estimated)', ...
'Aggregated (Estimated)')

% --
% Show the results for another period that is not the training
% --
data = data_orig;
data = data(2e4:2.3e4, :);
sel = any(isnan(data), 2);
data(sel, :) = [];

proxies = POA_proxies(data(:,3), data(:,1), location);      
M = proxies(:,:);
estimated_PV = M/1000 * alpha;

h1 = figure('position',[0,0,2000*8/10,800*8/10]); 
set(h1,'Units','Inches');
pos = get(h1,'Position');
%set(h1,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])




plot(data(:, 2), 'linewidth', 2)
hold on
plot(estimated_PV)
plot(data(:, 2) + estimated_PV)
hold off
xlabel('Samples'); ylabel('Active Power');

legend('Measured aggregated real power', ...
'Estimated PV generation', ...
'Estimated demand')
legend('location', 'northwest')

xlim([0, 2000])

set(gca,'fontsize',18)





