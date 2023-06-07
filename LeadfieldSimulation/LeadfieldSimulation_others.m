% x軸:後頭部から鼻、y軸:左耳から右耳、z軸:胴体から頭頂部
Subname = 'Mori';
vert_num = '15002';
dir = append(Subname, '/', vert_num);
save_ = 1;
want = 300;
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

censor_output_EEG=[];
censor_output_MEG=[];
for i=1:want
	N = randi([150, 250], 1, 1);
	scout = randi([1, 15002], N, 1);
	neuron_vertices = read_vertices(scout, vertices);
	neuron_gain_EEG = read_gain(scout, gain_EEG);
	neuron_gain_MEG = read_gain(scout, gain_MEG);
	tmp = rand(N,1);
	for k=1:length(tmp)
		if tmp(k) >= 0.7 && randi([1, 3],1,1) ~= 1
			tmp(k) = tmp(k) * rand(1,1);
		end
	end
	bold = rand(N, 1) * 1.054*10^2;
	censor_output_MEG = [censor_output_MEG, neuron_gain_MEG * bold];
	censor_output_EEG = [censor_output_EEG, neuron_gain_EEG * bold];
end
if save_==1
	save(append(Subname, '/', vert_num, '/MEG/others', '/censor_others.mat'), 'censor_output_MEG')
	save(append(Subname, '/', vert_num, '/EEG/others', '/censor_others.mat'), 'censor_output_EEG')
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