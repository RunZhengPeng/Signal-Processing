
function [ meanArray ] = processHydrophoneDataLinearFromCsv( folderName )

%% Import data from text file.
% Script for importing data from the following text file:
%
%    D:\scan\hydrophone_scans\CSV\4MHz\4M_20.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2016/08/05 08:41:02

    %% Initialize variables.
    %filename = 'D:\scan\hydrophone_scans\CSV\4MHz\4M_20.csv';

    [scan, numScan] = importDataFromCsv(folderName);

    %% Use moving average filter to smooth the data points
    N = 8;
    b = (1/N)*ones(1, N);
    a = 1
    for index = 1:numScan
        scanFilt(index,:) = filtfilt(b, a, scan(index,:));  
    end

    %%
%     figure
%     plot(scanFilt(5,:))
%     hold on
%     plot(scan(5,:))
%     grid on
    for index = 1:numScan
        
        signalSegment = scanFilt(index,8000:end);
        peakDistance = 200;
        % Calculate 6 max and min peaks for signal
        [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance);

        % Sum max and min to calculate "peak2peak" value
        peak2peakArray = maxPeaks - minPeaks;

        % Calculate mean
        meanArray(index) = mean(peak2peakArray);   
    end
    
end
function [maxPeaks, locsMax, minPeaks, locsMin] = findMaxAndMinPeaks(signalSegment, peakDistance)

    
    peakDistanceModified = peakDistance;
    signalSegment_interp = signalSegment;
    [pksMax, locsMax] = findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    %findpeaks(signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    [pksMin, locsMin] = findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    %findpeaks(-signalSegment_interp,'MinPeakDistance',  peakDistanceModified);
    
    % Only keep peaks 3 to 8
    if((length(pksMax) >= 17 && (length(pksMin) >= 17)))
        maxPeaks = pksMax(5:12);
        minPeaks = -pksMin(5:12);      
        locsMax  = locsMax(5:12);
        locsMin  = locsMin(5:12);
    elseif(length(pksMax) > 2)
        error('Error Should find more than 17 peaks')
        lengthMax = length(pksMax);
        lengthMin = length(pksMin);
        if(lengthMax > lengthMin)
            maxLength = lengthMin;
        else
            maxLength = lengthMax;
        end
        
        maxPeaks = pksMax(1:maxLength);
        minPeaks = -pksMin(1:maxLength);      
        locsMax  = locsMax(1:maxLength);
        locsMin  = locsMin(1:maxLength);

    else
        error('Error in finding peaks')
    end            
    
end
function [scan, numScan] = importDataFromCsv(folderName)
    delimiter = '';
    startRow = 2;


    %%
    listing = dir(folderName);

    % Read data filename into dataFiles cell array
    fileIndex = 1;
    for index = 1:size(listing,1)
        if(0 == listing(index).isdir)
            dataFiles(fileIndex) = cellstr(listing(index).name);
            fileIndex = fileIndex + 1;
        end
    end

    dataFiles = sort(dataFiles');

    %%

    %% Format string for each line of text:
    %   column1: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%f%[^\n\r]';

    scan = zeros(length(dataFiles), 12500);

    for index = 1:length(dataFiles)
        filename = char(strcat('D:\scan\hydrophone_scans\CSV\4MHz\',dataFiles(index)));
        fileID = fopen(filename,'r');    
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);    
        fclose(fileID);    
        scan(index,:) = dataArray{:, 1};
    end
    
    numScan = length(dataFiles);
end
