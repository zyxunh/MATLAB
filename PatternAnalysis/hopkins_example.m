function hopkins_example
% example of hopkins statistics analysis of the data

% generate synthetic data with 1000 datapoints in the area [10, 45, 20, 60]
dataXY_all = generateNoise(1000, [10, 50, 20, 70]);


% ROI
xlim1=15; xlim2 = 45; ylim1 = 30; ylim2 = 70; 
plotROI = 1; %plot data with selected ROI
% select region of interest (ROI) of the data ans plots:
dataXY = ROIdata(dataXY_all, xlim1, xlim2, ylim1, ylim2, plotROI);

% plot data in red color in size 5
colorData = 'r'; sizeData = 5;
figure
plotData(dataXY, [xlim1, xlim2, ylim1, ylim2], colorData, sizeData)

% plot data in default
figure
plotData(dataXY)


% computes histogram H of Hopkins statistics for m random events and points
% histogram is computed from N repetition of the process. Histogram is
% computed in Nbins bins.
% 
% 
m=10;
N = 1000;
Nbins = 100;
envelopes = 1; % computes silmulation envelopes
Nsimul = 3; % number of simulations for envelope coputation
filename = 'HopkinsStat_example'; % name of the file where H function values are stored

[xH, H, HNMax, HNMin] = hopkins_main (dataXY_all, xlim1, xlim2, ylim1, ylim2, m, N, Nbins, envelopes,Nsimul, filename);
 

% plot K function with theoretical line for Poisson process K_p = pi*xK^2:
plot (xH, H, xH, hopkins_poiss(xH,m), '--k')

% plot simulation envelopes:
hold on 
plot (xH, HNMax, '-.r', xH, HNMin, '-.r')

%fiting:
errval = ones(size(H)); %error in L function - set equal for all values...
initval = [1 1]; %initial values of the fit

[pbestH,perrorH,nchiH]=nonlinft('fitH' ,xH,H,errval,initval,[1 1]);

% mena of the fitted beta distribution
% pbestH(1) - alpha
% pbestH(2) - beta

meanH= pbestH(1)/(pbestH(1)+pbestH(2));


%plot fit
figure
plot(xH, H, xH, fitH(xH, pbestH),'r')

fH = fitH(xH, pbestH);
% save fit values in file
filename_fit = 'Hopkins_fit';
writedata(xH, fH, pbestH, filename_fit, 'fit of Hopkins statistics' )


 