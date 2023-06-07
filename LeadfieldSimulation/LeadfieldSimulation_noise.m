% パラメータ設定
% save_ = 1;
% Subname = 'Sakamoto';
% megeeg = 'MEG';
% num_noise = '100';
% vert_num = '15002';
% dir = append(Subname, '/', vert_num);
% testornot = 'test_'; %test:'test_', train:''
% a = 2; %部位指定1:lower, 2:upper
if strcmp(Subname, 'Sakamoto')
	meg_num_sensor = '1139';
	eeg_num_sensor = '899';
elseif strcmp(Subname, 'Sugino')
	meg_num_sensor = '1093';
	eeg_num_sensor = '882';
elseif strcmp(Subname, 'Mori')
	meg_num_sensor = '1154';
	eeg_num_sensor = '917';
end

%%
pial = load(fullfile(dir,"tess_cortex_pial.mat"));
vertices = pial.Vertices;

gain_MEG = load(append(dir, '/MEG_Gain_constrained_', meg_num_sensor, '.mat')).Gain_constrained;
channel_MEG = load(append(dir, '/MEG_channel_', meg_num_sensor, '.mat'));
censor_pos_MEG = read_channel(channel_MEG.Channel);
gain_EEG = load(append(dir, '/EEG_Gain_constrained_', eeg_num_sensor, '.mat')).Gain_constrained;
channel_EEG = load(append(dir, '/EEG_channel_', eeg_num_sensor, '.mat')).Channel;
censor_pos_EEG = read_channel_EEG(channel_EEG);

if strcmp(megeeg, 'MEG')
	scout_lower = load(append(dir, '/', megeeg, '/lower_', meg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num; %MEG,EEGどちらも同じ。
	scout_upper = load(append(dir, '/', megeeg, '/upper_', meg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num;
	scout_ul = load(append(dir, '/', megeeg, '/ul_', meg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num;
	bold_lower = load(append(dir, '/', megeeg, '/lower_', meg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
	bold_upper = load(append(dir, '/', megeeg, '/upper_', meg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
	bold_ul = load(append(dir, '/', megeeg, '/ul_', meg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
elseif strcmp(megeeg, 'EEG')
	scout_lower = load(append(dir, '/', megeeg, '/lower_', eeg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num; %MEG,EEGどちらも同じ。
	scout_upper = load(append(dir, '/', megeeg, '/upper_', eeg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num;
	scout_ul = load(append(dir, '/', megeeg, '/ul_', eeg_num_sensor, '/', testornot,'vertice_noise_', num_noise, '.mat')).noise_plot_vertice_num;
	bold_lower = load(append(dir, '/', megeeg, '/lower_', eeg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
	bold_upper = load(append(dir, '/', megeeg, '/upper_', eeg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
	bold_ul = load(append(dir, '/', megeeg, '/ul_', eeg_num_sensor, '/', testornot,'bold_noise_', num_noise, '.mat')).noise_bold_on_vertice;
end

%%
noise_censor_EEG = {};
noise_censor_MEG = {};
for k=1:length(bold_upper)
	lower_vertices = read_vertices(scout_lower{k}, vertices);
	upper_vertices = read_vertices(scout_upper{k}, vertices);
	lower_bold = read_bold(scout_lower{k}, bold_lower{k});
	upper_bold = read_bold(scout_upper{k}, bold_upper{k});
	lower_gain_MEG = read_gain(scout_lower{k}, gain_MEG);
	upper_gain_MEG = read_gain(scout_upper{k}, gain_MEG);
	lower_gain_EEG = read_gain(scout_lower{k}, gain_EEG);
	upper_gain_EEG = read_gain(scout_upper{k}, gain_EEG);
	lower_num = length(lower_vertices);
	upper_num = length(upper_vertices);

	ul_vertices = read_vertices(scout_ul{k}, vertices);
	ul_bold = read_bold(scout_ul{k}, bold_ul{k});
	ul_gain_MEG = read_gain(scout_ul{k}, gain_MEG);
	ul_gain_EEG = read_gain(scout_ul{k}, gain_EEG);
	ul_num = length(ul_vertices);

	bold_max = max([max(upper_bold), max(lower_bold), max(ul_bold)]);
	
	%新部位追加の一連のフォーマット
	% scout_visual = load(fullfile(append(dir,'/noise_visual_1066'), 'vertice_noise.mat')).noise_plot_vertice_num
	% visual_vertices = read_vertices(scout_visual{k}, vertices);
	% visual_gain_EEG = read_gain(scout_visual{k}, gain_EEG);
	% visual_gain_MEG = read_gain(scout_visual{k}, gain_MEG);
	% visual_num = length(visual_vertices)
	
	%% 部位指定
	if a==1
		neuron_vertices = lower_vertices;
		neuron_gain_MEG = lower_gain_MEG;
		neuron_gain_EEG = lower_gain_EEG;
		bold = lower_bold;
		Neuron_num = lower_num;
	elseif a==2
		neuron_vertices = upper_vertices;
		neuron_gain_MEG = upper_gain_MEG;
		neuron_gain_EEG = upper_gain_EEG;
		bold = upper_bold;
		Neuron_num = upper_num;
	elseif a==3
		neuron_vertices = ul_vertices;
		neuron_gain_MEG = ul_gain_MEG;
		neuron_gain_EEG = ul_gain_EEG;
		bold = ul_bold;
		Neuron_num = ul_num;
	end
	
	bold = bold / bold_max * 1.054*10^2;
	
	%% MEG順問題
	noise_censor_MEG{k} = neuron_gain_MEG * bold;
	
	%% EEG順問題
	noise_censor_EEG{k} = neuron_gain_EEG * bold;
end

if save_ == 1
	if a==1
		txt = '/lower_';
	elseif a==2
		txt = '/upper_';
	elseif a==3
		txt = '/ul_';
	end
	if strcmp(megeeg, 'MEG')
		save(append(dir, '/', megeeg, txt, meg_num_sensor, '/', testornot,'censor_noise_', num_noise, '.mat'), "noise_censor_MEG")
	elseif strcmp(megeeg, 'EEG')
		save(append(dir, '/', megeeg, txt, eeg_num_sensor, '/', testornot,'censor_noise_', num_noise, '.mat'), "noise_censor_EEG")
	end
end

%% 関数ブロック
function out = read_channel_EEG(channel)
	tmp = [];
	for i = 1:length(channel)
		if length(channel(i).Loc) == 3
			tmp = cat(1, tmp, [channel(i).Loc(1), channel(i).Loc(2), channel(i).Loc(3)]);
		else
			tmp = cat(1, tmp, [0, 0, 0]);
		end
	end
	out = tmp;
end

function out = read_channel(channel)
	tmp = [];
	for i = 1:length(channel)
		if length(channel(i).Loc) == 8
			tm = mean(channel(i).Loc, 2);
			tmp = cat(1, tmp, [tm(1), tm(2), tm(3)]);
		else
			tmp = cat(1, tmp, [0, 0, 0]);
		end
	end
	out = tmp;
end

function out = read_gain(x, g)
	tmp = [];
	for i = 1:length(x)
		tmp = cat(2, tmp, g(:,x(i)));
	end
	out = tmp;
end

function out = read_bold(x, b)
	tmp = [];
	for i = 1:length(x)
		tmp = cat(1, tmp, b(x(i)));
	end
	out = tmp;
end

function ver = read_vertices(x, v)    %x:Scouts.Vertices, v:pial.Vertices
    tmp = [];
    for i = 1:length(x)
        tmp = cat(1, tmp, v(x(i),:));
    end
    ver = tmp;
end