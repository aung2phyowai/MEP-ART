function display_average_emg(app, param)

switch param
	case 'start'
		init_avg_emg_fig(app)
		% If there is not a figure with the name 'emg data', then
		% we are not getting live data from magstim & brainvision.
		% We are probably debugging or want to enter data from a file.
		h_emg = findobj(0, 'Name', 'EMG Data');
		if isempty(h_emg)
			% Add button to load data
			h = uicontrol(app.avg_emg_fig, 'Style', 'pushbutton', ...
				'String', 'Load Data', ...
				'Units', 'normalized', ...
				'Position', [0.05 0.018 0.25 0.065], ...
				'Fontsize', 20, ...
				'Callback', {@load_stim_emg_data, app});
		end
		
	case 'stop'
		close(app.avg_emg_fig)
end 
