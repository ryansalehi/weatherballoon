%% Ryan Salehi
% --- Tentative Team Three
clear
close all

%file info
file='main_cold.txt';
data2=readtable(file);
data_height=height(data2);

%% GPS DATA (GPGGA)

%create an example in order to make the table with correct size/type
gpsexample='$GPGGA,233905.000,4217.1402,N,08344.0823,W,1,08,1.15,237.6,M,-34.0,M,,';
gpsexampleheader=strsplit(gpsexample,',');
goodgpsCells=gpsexampleheader;

%loop through and look for good gps data
for i=1:data_height
    temp=cell2mat(data2{i,1});
    k1=strfind(temp,"$GPGGA");
    k2=strfind(temp,"W");
    k3=length(k1)>=1;
    k4=length(k2)>=1;
    k5=k3&&k4;
    newStr=strsplit(temp,',');
    if (k5)
        goodgpsCells=[goodgpsCells;newStr];
    end
end

%remove the exampleheader from data
goodgpsCells(1,:)=[];

%pull out lat/lon from table and put into separate arrays
latitudesCells=goodgpsCells(:,3);
latitudes=zeros(height(latitudesCells),1);
longitudesCells=goodgpsCells(:,5);
longitudes=zeros(height(longitudesCells),1);
for i=1:height(latitudesCells)
    latitudes(i,1)=str2double(latitudesCells{i,1});
    latitudes(i,1)=nmea2deg(latitudes(i,1));
    longitudes(i,1)=str2double(longitudesCells{i,1});
    longitudes(i,1)=nmea2deg(longitudes(i,1)).*-1;
end


%% Plot GPS
figure(1)
geoplot(latitudes,longitudes,'Color','r')
geobasemap topographic

%% Main Data

%create an example in order to make the table with correct size/type
dataexample='DATA: ,14.28, 20.44, 30.21, 96.82, -0.29, 0.73, -0.27,1007117';
dataexampleheader=strsplit(dataexample,',');
dataCells=dataexampleheader;

%loop through and look for "DATA" data strings. Add any lines with "DATA"
%are added to the dataCells table
for i=1:data_height
    temp=cell2mat(data2{i,1});
    k6=strfind(temp,"DATA");
    newStr=strsplit(temp,',');
    if (k6)
        dataCells=[dataCells;newStr];
    end
end

%remove the exampleheader from data
dataCells(1,:)=[];

%pull out data from table cells and put into separate arrays
tmp1Cells=dataCells(:,2);
tmp1=zeros(height(tmp1Cells),1);
tmp2Cells=dataCells(:,3);
tmp2=zeros(height(tmp2Cells),1);
pressureCells=dataCells(:,4);
pressure=zeros(height(pressureCells),1);
humidityCells=dataCells(:,5);
humidity=zeros(height(humidityCells),1);
xaccelCells=dataCells(:,6);
xaccel=zeros(height(xaccelCells),1);
yaccelCells=dataCells(:,7);
yaccel=zeros(height(yaccelCells),1);
zaccelCells=dataCells(:,8);
zaccel=zeros(height(zaccelCells),1);
timeCells=dataCells(:,9);
time=zeros(height(timeCells),1);
for i=1:height(dataCells)
    tmp1(i,1)=str2double(tmp1Cells{i,1});
    tmp2(i,1)=str2double(tmp2Cells{i,1})-454;
    pressure(i,1)=str2double(pressureCells{i,1});
    humidity(i,1)=str2double(humidityCells{i,1});
    xaccel(i,1)=str2double(xaccelCells{i,1});
    yaccel(i,1)=str2double(yaccelCells{i,1});
    zaccel(i,1)=str2double(zaccelCells{i,1});
    time(i,1)=str2double(timeCells{i,1})./1000;
end

%fix any time jumps from arduino being powered on/off
timesToFix=1;
for j=1:timesToFix
    lastgoodtime=[];
    for i=2:height(timeCells)
        if time(i,1)<time(i-1,1)
            lastgoodtime=[lastgoodtime;time(i-1,1)];
            time(i,1)=time(i,1)+lastgoodtime(1);
        end
    end
end
%% Data plots

figure(2);
plot(time,xaccel);
title("X-Axis Acceleration vs. Time");
ylabel("X-Axis Acceleration (G)");
xlabel("Time (s)")

figure(3);
plot(time,yaccel);
title("Y-Axis Acceleration vs. Time");
ylabel("Y-Axis Acceleration (G)");
xlabel("Time (s)")

figure(4);
plot(time,zaccel);
title("Z-Axis Acceleration vs. Time");
ylabel("Z-Axis Acceleration (G)");
xlabel("Time (s)")

figure(5);
plot(time,tmp1);
title("Outside Temperature vs. Time");
ylabel("Outside Temperature (deg C)");
xlabel("Time (s)")


figure(6);
plot(time,tmp2);
title("Inside Temperature vs. Time");
ylabel("Inside Temperature (deg C)");
xlabel("Time (s)")


figure(7);
plot(time,pressure);
title("Pressure vs. Time");
ylabel("Pressure (mmHg)");
xlabel("Time (s)")

figure(8);
plot(time,humidity);
title("Outside Humidity vs. Time");
ylabel("Outside Humidity Percentage");
xlabel("Time (s)")

figure(9);
plot(time,tmp1,time,tmp2)
title("Temperature vs. Time");
ylabel("Temperature (deg C)");
xlabel("Time (s)")
legend("Outside Temperature","Inside Temperature");
xlim([0 7200]);

%% Helper function

%convert from nmea to degrees
function varout = nmea2deg(varin)
error(nargchk(1, 2, nargin, 'struct'));
  
  for i = 1:height(varin)
    nmea = varin(i);
    deg = fix(nmea/100) + rem(nmea,100)/60;
    varout(i) = deg;
  end

end



