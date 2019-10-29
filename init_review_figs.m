function init_review_figs(app)

if isempty(app.emg_data_fig) || ~isgraphics(app.emg_data_fig)
	app.emg_data_fig = figure('Position', [466 86  1160  1000], 'Name', 'EMG Data', ...
		'NumberTitle', 'off');
	app.h_disp_emg_axes = axes('Position', [0.6, 0.55,0.37,0.37], 'FontSize', 16);
	ylabel('EMG (�V)')
	xlabel('Time (msec)')
	
	app.h_uitable = uitable('Position', [31 66 580 837], 'RowName', []);
	
	% radiobuttons to choose how to compute MEP 
	app.h_radio_mep = uibuttongroup('Position', [0.1 0.92 0.125 0.065], ...
		'Title', 'MEP Calculation', ...
		'SelectionChangedFcn',{@mep_button_selection, app});
	r1 = uicontrol(app.h_radio_mep,'Style', 'radiobutton',...
                  'String','Peak-to-Peak',...
                  'Position',[2 25 90 25],...
                  'HandleVisibility','off', ...
				  'Tag', 'rb_mep_pp');
	r2 = uicontrol(app.h_radio_mep,'Style', 'radiobutton',...
                  'String','Area Under the Curve',...
                  'Position',[2 7 150 20],...
                  'HandleVisibility','off', ...
				  'Tag', 'rb_mep_auc');
% 	app.preEmgMinEditField = uicontrol('Position', [0.3 0.92 0.2 0.1], ...
% 		'Style', 'edit', 'String', '-100');
	
	% mep begin & end times
	app.h_edit_mep_begin = uicontrol('Style', 'edit', ...
		'Position', [0.7, 0.4, 0.2, 0.1]);
	app.h_edit_mep_end = uicontrol('Style', 'edit', ...
		'Position', [0.8, 0.4, 0.2, 0.1]);
	
	% get parameters from text file
	parameter_file = 'parameters.txt';
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
	keywords = { 'freq'  'pre' 'post'};
	defaults = { 1000, 50, 100};
	paramscell = readparamfile(parameter_file, keywords, defaults);
	app.params.sampFreq  = paramscell{1};
	app.params.preTriggerTime  = paramscell{2};
	app.params.postTriggerTime = paramscell{3};
   
   
	seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
	seg_num_points = round(app.params.sampFreq*seg_time);
	t = (0:1/app.params.sampFreq:(seg_time-1/app.params.sampFreq))*1000 - app.params.preTriggerTime;

	% data line
	app.h_emg_line = line(app.h_disp_emg_axes, t, zeros(1, seg_num_points), ...
	  'LineWidth', 3) ;

	% lines at x,y = 0,0
	line(app.h_disp_emg_axes, app.h_disp_emg_axes.XLim, [0 0]);
	line(app.h_disp_emg_axes, [0 0], [-1e6 1e6]);

	% min & max vertical lines - draggable
	app.h_t_min_line = line(app.h_disp_emg_axes, [15 15], [-1e6 1e6], ...
	  'LineWidth', 2, 'Color', [0 0.9 0], 'UserData', app, 'Tag', 'mep_min_line');
	draggable(app.h_t_min_line, 'h', [0 200], 'endfcn', @mep_line_drag_endfcn)
	app.h_t_max_line = line(app.h_disp_emg_axes, [90 90], [-1e6 1e6], ...
	  'LineWidth', 2, 'Color', [0 0.9 0], 'UserData', app, 'Tag', 'mep_max_line');
	draggable(app.h_t_max_line, 'h', [0 200], 'endfcn', @mep_line_drag_endfcn)
	
	% pre-stim emg line
	app.h_pre_stim_emg_line = line(app.h_disp_emg_axes, ...
		app.h_disp_emg_axes.XLim, [1000 1000], 'Color', [0 0 0]);
	
	% emg auc line
	app.h_emg_auc_patch = patch(app.h_disp_emg_axes, ...
		[10 10 90 90], [10 100 100 10], [0.4 0.4 0.4]);
	app.h_emg_auc_patch.FaceAlpha = 0.5;
	app.h_emg_auc_patch.Visible = 'off';

else
	% reset the data line
	seg_time = (app.params.postTriggerTime + app.params.preTriggerTime) / 1000;
	seg_num_points = round(app.params.sampFreq*seg_time);
	app.h_emg_line.YData = zeros(1, seg_num_points);

	% reset the mep min max lines
	app.h_t_min_line.XData = [15 15];
	app.h_t_max_line.XData = [90 90];
	
	% reset prestim line & emg auc patch
	app.h_pre_stim_emg_line.YData = [1000 1000];
	app.h_emg_auc_patch.Vertices = [];
	app.h_emg_auc_patch.Faces = [];
end

title(app.h_disp_emg_axes, strrep(app.MuscleEditField.Value, '_', ' '))

% ======= rc or sici fig ===========
if app.ButtonRc.Value == 1
	init_rc_fig(app)
	if isgraphics(app.sici_fig)
		delete(app.sici_fig)
	end
else
	init_sici_fig(app)
	if isgraphics(app.rc_fig)
		delete(app.rc_fig)
	end
end

% % text display of MEP amplitude
% app.mep_value_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
% 			'String', num2str(1000), ...
% 			'Units', 'normalized', ...
% 			'Position', [0.7 0.85 0.29 0.14], ...
% 			'Fontsize', 50, 'ForegroundColor', 'b');
% 
% % text display of pre-emg value
% app.pre_emg_text = uicontrol(app.emg_data_fig, 'Style', 'text', ...
% 			'String', num2str(0), ...
% 			'Units', 'normalized', ...
% 			'Position', [0.08 0.06 0.13 0.075], ...
% 			'Fontsize',18, 'ForegroundColor', 'b');