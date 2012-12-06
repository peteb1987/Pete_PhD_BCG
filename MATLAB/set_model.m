% Set model parameters

% Basics
model.K = 1000;                                  % Number of observations
model.fs = 30;                                  % Sampling frequency of observations (after load_and_calibrate, which downsamples)
model.dp = 1;                                   % Number of changepoint parameter dimensions (beat period)
model.dw = 40;                                  % Number of samples in the beat waveform

% Priors
% load('template_beat.mat');
% model.w_prior_mn = template;
% model.w_prior_vr = 0.1*eye(model.dw, model.dw);
model.w_prior_mn = zeros(model.dw,1);
model.w_prior_vr = 10*eye(model.dw, model.dw);
model.p_prior_shape = 40;
model.p_prior_scale = 0.03;
model.b_prior_shape = 3;
model.b_prior_scale = 0.4;


% Transition models
model.tau_trans_shape = 3;                      % Changepoint time transition density (shifted inverse-gamma) shape paramter
model.tau_trans_scale = 0.4;                    % Changepoint time transition density (shifted inverse-gamma) scale paramter
model.p_trans_scale = 1E-4;                     % Beat period transition density (gamma) scale (shape is the previous value/scale)
model.w_trans_vr = 0.003*eye(model.dw);         % Waveform transition density (normal) covariance matrix (mean is the previous value)

% Clutter
model.clut_trans = [0.999 0.1; 0.001 0.9];      % Clutter indicator transition matrix
model.y_clut_vr = 20^2;                         % Clutter observation variance

% Observation model
model.y_obs_vr = 0.5^2;                         % Observation variance
