function [ time, bcg_out, beats1, beats2 ] = load_and_calibrate(K, datafilename, calibfilename, t_start, t_stop, offset)

% Set things
dsr = 8;            % Down sampling ratio - sets low pass filter cut-off (5 --> 30Hz)

% Constants
fs = 240;

% Derivative constants
fhigh = fs/(2*dsr);
flow = 0.2;

% Load data
load(datafilename);
if ~exist('t', 'var')
    t = (1:size(F,1))*63;
end

% Pick out a nice chunk to work on
t_idx = find((t>t_start)&(t<t_stop));
bcg = F(t_idx,:);
ecg = E(t_idx,:);

% Extract beats from ECG
[beats1] = ecgdetect(ecg(:,1),fs,1.5,0);
[beats2] = ecgdetect(ecg(:,2),fs,1.5,0);

% Low pass filter to remove 50Hz
% b = fir1(300, [flow fhigh]/(fs/2));
b = fir1(300, fhigh/(fs/2)) - ones(1,301)/301;
bcg_filt = zeros(size(bcg));
ecg_filt = zeros(size(ecg));
for ss = 1:4
    bcg_filt(:,ss) = filtfilt(b, 1, bcg(:,ss));
end
for ss = 1:2
    ecg_filt(:,ss) = filtfilt(b, 1, ecg(:,ss));
end

% Remove DC offset from bcg
bcg_filt = bsxfun(@minus, bcg_filt, mean(bcg_filt));

% Downsample
bcg_filt = bcg_filt(1:dsr:length(t_idx),:);

% Calibrate
% load(calibfilename)


% Time
time = (0:size(bcg_filt,1)-1)/(fs/dsr);

% Chop beats
beats1(beats1(:,1)>time(offset+K),:) = [];
beats2(beats2(:,1)>time(offset+K),:) = [];
beats1(beats1(:,1)<time(offset),:) = [];
beats2(beats2(:,1)<time(offset),:) = [];

% Select a little chunk
bcg_out = bcg_filt(offset+1:offset+K,:)';
time = time(offset+1:offset+K);

% Correct if its from the newer sets
if   strcmp(datafilename,'../data/two_person/ash_jenz.mat') ...
  || strcmp(datafilename,'../data/two_person/ash_jing.mat') ...
  || strcmp(datafilename,'../data/two_person/ash_phil.mat')
    bcg_out = bcg_out/2000;
end

% Shift time by offset
t_off = time(1);
time = time - t_off;
beats1(:,1) = beats1(:,1) - t_off;
beats2(:,1) = beats2(:,1) - t_off;

end
