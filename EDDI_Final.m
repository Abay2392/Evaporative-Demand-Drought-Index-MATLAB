% Specify the path to the NetCDF file
filename = ('merged_ETo.nc');
lat=ncread(filename, "latitude");
lon=ncread(filename, "longitude");
time=ncread(filename, "time");
e=ncread(filename, "e");


% Specify the target latitude and longitude
latCAT = 37.441788;	
lonCAT = 15.067711;

% Find the indices corresponding to the specified location
latIndex = find(abs(lat - latCAT) == min(abs(lat - latCAT)), 1);
lonIndex = find(abs(lon - lonCAT) == min(abs(lon - lonCAT)), 1);

% Extract 'e' and 'time' data for the specified location
eData = ncread(filename, 'e', [lonIndex, latIndex, 1], [1, 1, Inf]);
timeData = ncread(filename, 'time');
time1=datenum(timeData);

eData = abs(squeeze(eData)).*1000;

%Extract every 24th evaporation and date value until the end
ET_daily = (eData(24:24:end));
timedaily = timeData(24:24:end);
% Convert int64 to datetime
timestamp = int64(timedaily); % Replace this with your actual int64 value

% Convert int64 timestamp to datetime
dt = datetime(timestamp, 'ConvertFrom', 'posixtime');
% Display the date in a specific format

% Define start and end dates
startDate = datetime('01-Jan-1950');
endDate = datetime('29-Sep-2023');

% Generate a sequence of dates
dates = startDate:endDate;

%EDDI computation
k =14;
t= double(timedaily);

e0 = ET_daily;

todd = find(month(t) == 2 & day(t)==29);
dates1=dates;
dates1(todd)=[];
e0(todd) = [];
t(todd) = [];
e0k = movsum(e0, [k-1 0]); % aggregated values corrected 6/2/2024
e0k(1:k) = NaN;

%altro approccio: elimino i 29 febbraio e vado di passo costante
eddikprob = nan(size(e0k));
eddiknquant = nan(size(e0k));
eddiprobclass =  nan(size(e0k));
x =cell(365, 1)
eddicl = [ [100 98 95 90 80 70 30 20 10 5 2 ]/100;  -[5 4 3 2 1 0 -1 -2 -3 -4 -5]]'  % eddi guide https://psl.noaa.gov/eddi/pdf/EDDI_UserGuide_v1.0.pdf even if 5

for i = 1: 365
    e0kday = e0k(i:365:end);
    x{i,1}=e0kday;
    pdlog(i) = fitdist(e0kday, "Loglogistic"); % loglogistic is the best according to https://rmets.onlinelibrary.wiley.com/doi/epdf/10.1002/joc.7275
    eddikprob(i:365:end) = cdf(pdlog(i), e0kday);
    eddiknquant(i:365:end) = norminv(cdf(pdlog(i), e0kday),0,1);
    clprb = interp1(eddicl(:,1),  eddicl(:,2),  eddikprob(i:365:end) , 'Nearest');
    eddiprobclass(i:365:end)= clprb;
end

%cdf, gather, icdf, iqr, mean, median, negloglik, paramci, pdf, plot, proflik, random, std, truncate,  var
%we are interested just in this first plot EDDI (probability)
figure
subplot(3,1,1)
plot(dates1,eddikprob)
title(strcat('Percentiles: ', ' ', num2str(k), ' days'))
ylabel("Percentiles")
set(gca, 'FontWeight', 'bold');
hold on
plot([dates1(1) dates1(end)] , [0.98 0.98], '--r')
hold on
plot([dates1(1) dates1(end)] , [0.95 0.95], '--g')
subplot(3,1,2)
plot(dates1,eddiknquant)
title(strcat('EDDI: ', ' ', num2str(k), ' days'))
ylabel ('EDDI')
set(gca, 'FontWeight', 'bold');

subplot(3,1,3)
plot(dates1,e0k);
title(strcat('Aggregate: ', ' ', num2str(k), ' days'))
ylabel ('ETo (mm/15 days)')
set(gca, 'FontWeight', 'bold');


% subplot(3,1,3)
% plot(dates1,eddiprobclass)
 



% datetick ('x', 'yyyy');
