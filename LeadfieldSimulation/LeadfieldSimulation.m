% x軸:後頭部から鼻、y軸:左耳から右耳、z軸:胴体から頭頂部
% Subname = 'Mori';
% vert_num = '15002';
% dir = append(Subname, '/', vert_num);
% a = 2; %部位指定1:lower, 2:upper
% save_ = 1;
% megeeg = 'MEG';
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

scout_lower = load(append(dir, '/', megeeg, '/scout_vertice_lower.mat')).plot_vertice_num;
scout_upper = load(append(dir, '/', megeeg, '/scout_vertice_upper.mat')).plot_vertice_num;
bold_lower = load(append(dir, '/', megeeg, '/bold_on_vertice_lower.mat')).bold_on_vertice;
bold_upper = load(append(dir, '/', megeeg, '/bold_on_vertice_upper.mat')).bold_on_vertice;
lower_vertices = read_vertices(scout_lower, vertices);
upper_vertices = read_vertices(scout_upper, vertices);
lower_bold = read_bold(scout_lower, bold_lower);
upper_bold = read_bold(scout_upper, bold_upper);
lower_gain_MEG = read_gain(scout_lower, gain_MEG);
upper_gain_MEG = read_gain(scout_upper, gain_MEG);
lower_gain_EEG = read_gain(scout_lower, gain_EEG);
upper_gain_EEG = read_gain(scout_upper, gain_EEG);
lower_num = length(lower_vertices);
upper_num = length(upper_vertices);

scout_ul = load(append(dir, '/', megeeg, '/scout_vertice_ul.mat')).plot_vertice_num;
bold_ul = load(append(dir, '/', megeeg, '/bold_on_vertice_ul.mat')).bold_on_vertice;
ul_vertices = read_vertices(scout_ul, vertices);
ul_bold = read_bold(scout_ul, bold_ul);
ul_gain_MEG = read_gain(scout_ul, gain_MEG);
ul_gain_EEG = read_gain(scout_ul, gain_EEG);
ul_num = length(ul_vertices);

bold_max = max([max(upper_bold), max(lower_bold), max(ul_bold)]);



%新部位追加の一連のフォーマット
% scout_visual = load(fullfile(dir, 'scout_vertice_lower_EEG1066.mat'));
% visual_vertices = read_vertices(visual, vertices);
% visual_gain_EEG = read_gain(visual, gain_EEG);
% visual_gain_MEG = read_gain(visual, gain_MEG);
% visual_num = length(visual_vertices)*2;

%% 部位,手法を指定
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
if strcmp(megeeg, 'MEG')
	censor_output_MEG = neuron_gain_MEG * bold;
	if save_==1
		if a==1
			save(append(Subname, '/', vert_num, '/', megeeg, '/lower_', meg_num_sensor, '/censor_main.mat'), 'censor_output_MEG')
		elseif a==2
			save(append(Subname, '/', vert_num, '/', megeeg, '/upper_', meg_num_sensor, '/censor_main.mat'), 'censor_output_MEG')
		elseif a==3
			save(append(Subname, '/', vert_num, '/', megeeg, '/ul_', meg_num_sensor, '/censor_main.mat'), 'censor_output_MEG')
		end
	end
	%% MEGセンサ出力プロット
	% figure()
	% censor_rec_min_MEG = min(min(censor_output_MEG));
	% censor_rec_max_MEG = max(max(censor_output_MEG));
	% scatter3(censor_pos_MEG(:,1), censor_pos_MEG(:,2), censor_pos_MEG(:,3), 10, censor_output_MEG(:), 'filled');
	% hold on
	% scatter3(neuron_vertices(:,1), neuron_vertices(:,2), neuron_vertices(:,3), 5, [0,0,0], 'filled');
	% hold off
	% caxis([censor_rec_min_MEG censor_rec_max_MEG])
	% daspect([1 1 1])
	% colormap default
	% colorbar
	% view(-60, 30)
%% EEG順問題
else
	censor_output_EEG = neuron_gain_EEG * bold;
	if save_==1
		if a==1
			save(append(Subname, '/', vert_num, '/', megeeg, '/lower_', eeg_num_sensor, '/censor_main.mat'), 'censor_output_EEG')
		elseif a==2
			save(append(Subname, '/', vert_num, '/', megeeg, '/upper_', eeg_num_sensor, '/censor_main.mat'), 'censor_output_EEG')
		elseif a==3
			save(append(Subname, '/', vert_num, '/', megeeg, '/ul_', eeg_num_sensor, '/censor_main.mat'), 'censor_output_EEG')
		end
	end
	
	%% EEGセンサ出力プロット
	% figure()
	% censor_rec_min_EEG = min(min(censor_output_EEG));
	% censor_rec_max_EEG = max(max(censor_output_EEG));
	% scatter3(censor_pos_EEG(:,1), censor_pos_EEG(:,2), censor_pos_EEG(:,3), 10, censor_output_EEG, "filled");
	% hold on
	% scatter3(neuron_vertices(:,1), neuron_vertices(:,2), neuron_vertices(:,3), 5, [0,0,0], 'filled');
	% hold off
	% caxis([censor_rec_min_EEG censor_rec_max_EEG])
	% daspect([1 1 1])
	% colormap default
	% colorbar
	% view(-60,30)
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