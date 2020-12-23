function [POA, SunZen] = POAirradiance(GHI, ts, pvl_location, tilt, azimuth)
% Computes plane-of array irradiance on an arbitrarily tilted plane with
% the hay-davies transposition model. Some parameter are set to a default
% value. See the code for more.
%
% Input:
% - GHI: global horizontal irradiance (W/m2)
% - ts: vector of UTC time in matlab format
% - pvl_location: pvlib location structure
% - tilt: tilt of panels (degree), 0 deg horizontal
% - azimuth: azimuth of the plant (degree), 180 south-facing
%
% Outputs:
% - POA: plane-of-array irradiance (W/m2)
% - SunZen: zenit angle of the sun

albedo = 0.1;


% Split GHI in DNI and DHI with disc model
pvl_time = pvl_maketimestruct(ts, ones(size(ts))*pvl_location.UTC);
dayOfYear = ts - datenum(year(ts), 1, 0);

%compute azimuth, elevation (90 - zenith) , apparent elevation and solar time. NB:can take additional arguments
[SunAz, SunEl, AppSunEl, ~] = pvl_ephemeris(pvl_time, pvl_location); 
Zenit = 90-SunEl;

DNI = pvl_disc(GHI, Zenit, dayOfYear); %DNI from disc model NB:can take additional arguments
DHI = GHI - cosd(Zenit).*DNI; %DHI form disc model


surfAz=ones(length(pvl_time.second),1).*azimuth; %generate vectors for parameters
surfTilt=ones(length(pvl_time.second),1).*tilt;  %generate vectors for parameters
Albedo=ones(length(pvl_time.second),1).*albedo;  %generate vectors for parameters

HExtra = pvl_extraradiation(dayOfYear);   %extraterrestrial irradiance
SunZen = 90 - AppSunEl;                   %real zenith
%AM = pvl_relativeairmass(SunZen);         %Air mass
%AM(isnan(AM)) = 20;


Id = pvl_haydavies1980(surfTilt, surfAz, DHI, DNI, HExtra, SunZen, SunAz);



%%Computation of Ig and Ib

Ig = pvl_grounddiffuse(surfTilt, GHI, Albedo); %irradiance from ground
AOI = pvl_getaoi(surfTilt, surfAz, SunZen, SunAz); % get AOI
% AOI2=acosd(sind(L_az).*cosd(90-L_tilt).*sind(SunAz).*cosd(SunEl)+cosd(L_az).*cosd(90-L_tilt).*cosd(SunAz).*cosd(SunEl)+sind(90-L_tilt).*sind(SunEl));
Ib = 0*AOI; %Initiallize variable
Ib(AOI<90) = DNI(AOI<90).*cosd(AOI(AOI<90)); %Only calculate when sun is in view of the plane of array


% Compute total Irradiation
POA = Id + Ib + Ig;


