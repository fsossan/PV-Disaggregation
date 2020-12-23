function [az, tilt] = generateProxies()
% Generate a base icosahedron mesh
TR=IcosahedronMesh();

% Subvivide the base mesh and visualize the results
% figure('color','w')
% subplot(2,3,1)
% h=trimesh(TR); set(h,'EdgeColor','b','FaceColor','w')
% axis equal
TRPlot=TR;
 for i=2:4
     TRPlot=SubdivideSphericalMesh(TRPlot,1);
 end

for i=2%:6
    %     subplot(2,3,i)
    TR=SubdivideSphericalMesh(TR,1);
    
    [azimuth,elevation]=cart2sph(TR.X(:,1),TR.X(:,2),TR.X(:,3));
    azdeg=azimuth/pi*180+180;
    eldeg=elevation/pi*180;
    sel=(azdeg>=50&azdeg<=310&eldeg>=0)| eldeg>50;
    sum(sel);
    az=azdeg(sel);
    el=eldeg(sel);
    tilt=90-el;
end