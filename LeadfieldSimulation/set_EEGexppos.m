%% set_censor_pos実行後に用いる。
Subname = 'Mori';
head_mask = load(fullfile(Subname, 'tess_head_mask.mat')).Vertices;
% vertice = head.Vertices;
% Channel = struct;
% s_leng = 0.00775/2;
% l_leng = 0.0500;

sensor_position = read_channel_EEG(mori_pos.Channel);
sensor_position = sensor_position(1:32,:);

%%
r = (sensor_position(:,1).^2+sensor_position(:,2).^2+sensor_position(:,3).^2).^0.5;
[k, dist] = dsearchn(head_mask, sensor_position);
sensor_position = sensor_position ./ r .* (r-dist+0.0015); %EEG

fileID = fopen(append('EEG/', Subname,'/', Subname, '2.pos'),'w');
for i=1:32
	fprintf(fileID, '%2.0f E%2.0f %8.9f %8.9f %8.9f\n', i, i, sensor_position(i,:));
end
fclose(fileID);


figure()
scatter3(head_mask(:,1), head_mask(:,2), head_mask(:,3), 3, [0.7, 0.7, 0.7]);
hold on
scatter3(sensor_position(:,1), sensor_position(:,2), sensor_position(:,3), 10, [0.4,0.4,1],'filled');
daspect([1,1,1])
hold off

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