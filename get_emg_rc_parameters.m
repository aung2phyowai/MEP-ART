function get_emg_rc_parameters(app, param_fname)

% read in parameters   
parameter_file = param_fname;
if ~exist(parameter_file, 'file')
  [filename, pathname] = uigetfile( ...
     {'*.txt';'*.*'}, ...
     'Choose Parameter File');
  parameter_file = fullfile(pathname, filename);
end
if ~exist(parameter_file, 'file')
  error( 'error finding parameter file, %s', parameter_file)
end
% read in the parameter file
keywords = {'addr' 'freq' 'period' 'chan' 'goal' 'pre' 'post' ...
	'baseline_emg_begin' 'baseline_emg_end' 'baseline_emg_method' ...
	'mep_p2p_method' 'mep_thresh'};
defaults = {'192.168.1.102', 2500, 0.5, 1, 0.2, 50, 100, -50, 0, 'mean_rect', 'abs', 200};
paramscell = readparamfile(parameter_file, keywords, defaults);
%            app.params.ipAddr    = paramscell{1};
app.params.sampFreq  = paramscell{2};
app.EMGSamplingFreqLabel.Text = ['EMG Sampling Freq: ' num2str(app.params.sampFreq) ' Hz'];
%            app.params.avgPeriod = paramscell{3};
%            app.params.dispChan  = paramscell{4};
app.params.goalPct   = paramscell{5};
app.ActivationGoalLabel.Text = ['Activation Goal: ' num2str(app.params.goalPct*100) '% mvc'];
app.params.preTriggerTime  = paramscell{6};
app.PreTriggerLabel.Text = ['Pre Trigger: ' num2str(app.params.preTriggerTime) ' ms'];
app.params.postTriggerTime = paramscell{7};
app.PostTriggerLabel.Text = ['Post Trigger: ' num2str(app.params.postTriggerTime) ' ms'];
app.preEmgMinEditField.Value = paramscell{8};
app.preEmgMaxEditField.Value = paramscell{9};
switch paramscell{10}
	case 'mean_rect'
		app.MeanRectifiedValueButton.Value = 1;
	case 'max_p2p'
		app.MaxPeaktoPeakButton.Value = 1;
	otherwise
		disp(['unknown baseline_emg_method in ' parameter_file]);
end

% 
% seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
% seg_num_points = round(app.params.sampFreq*seg_time);
% % time vector in msec
% t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;
 
           