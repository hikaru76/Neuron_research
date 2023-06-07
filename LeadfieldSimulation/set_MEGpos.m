% set_censor_pos実行後に用いる。
% MEGのファイル形式で保存
% 構造体Channelを適当な名前で保存して，Brainstormに取り込む．(import channel file→MEG/EEG: Brainstorm(channel*.mat))
Subname = 'Mori';
head = load(fullfile(Subname, "tess_head_mask.mat"));
vertice = head.Vertices;
Channel = struct;
s_leng = 0.00775/2;
l_leng = 0.0500;

for i=1:length(sensor_position)
	Channel(i).Name = append('A', num2str(i));
	Channel(i).Comment = 'MIT KIT system gradiometer size = 15.50  mm base = 50.00  mm';
	Channel(i).Type = 'MEG';
	Channel(i).Group = [];
end

TR = triangulation(head.Faces, vertice(:,1), vertice(:,2), vertice(:,3));
P = incenter(TR);
F = faceNormal(TR);

len_list = ones(length(P), length(sensor_position));
for i=1:length(sensor_position)
	len_list(:,i) = (P(:,1)-sensor_position(i,1)).^2+(P(:,2)-sensor_position(i,2)).^2+(P(:,3)-sensor_position(i,3)).^2;
end

[min_distance_list, min_distance_id] = mink(len_list, 1, 1);
vecpos = [];
vertical_vec = [];
horizontal_vec1 = [];
horizontal_vec2 = [];
for i=1:length(min_distance_id)
	vecpos = [vecpos; [P(min_distance_id(i),1),P(min_distance_id(i),2),P(min_distance_id(i),3)]];
	m = [F(min_distance_id(i),1),F(min_distance_id(i),2),F(min_distance_id(i),3)];
	vertical_vec = [vertical_vec; m];
	b=vertice(head.Faces(min_distance_id(i), 1),:);
	c=vertice(head.Faces(min_distance_id(i), 2),:);
	l=(b-c)/sum((b-c).^2)^0.5;
	horizontal_vec1 = [horizontal_vec1; l];
	horizontal_vec2 = [horizontal_vec2; cross(m,l)];
	d=[(sensor_position(i,:)+horizontal_vec1(i,:)*s_leng).' (sensor_position(i,:)-horizontal_vec1(i,:)*s_leng).' (sensor_position(i,:)+horizontal_vec2(i,:)*s_leng).' (sensor_position(i,:)-horizontal_vec2(i,:)*s_leng).' (sensor_position(i,:)+horizontal_vec1(i,:)*s_leng-vertical_vec(i,:)*l_leng).' (sensor_position(i,:)-horizontal_vec1(i,:)*s_leng-vertical_vec(i,:)*l_leng).' (sensor_position(i,:)+horizontal_vec2(i,:)*s_leng-vertical_vec(i,:)*l_leng).' (sensor_position(i,:)-horizontal_vec2(i,:)*s_leng-vertical_vec(i,:)*l_leng).'];
	Channel(i).Loc = d;
	Channel(i).Orient = repmat(vertical_vec(1,:).', [1,8]);
end
% figure()
% scatter3(sensor_position(:,1), sensor_position(:,2), sensor_position(:,3), 10, [0,0,0], "filled");
% hold on
% % scatter3(vecpos(:,1), vecpos(:,2), vecpos(:,3), 10, [1,0,0], "filled");
% for i=1:length(sensor_position)
% 	scatter3(Channel(i).Loc(1,:),Channel(i).Loc(2,:),Channel(i).Loc(3,:), 10, [0,1,0], "filled");
% end
% daspect([1 1 1]);
% hold off

for i=1:length(sensor_position)
	Channel(i).Weight = [0.250000000000000,0.250000000000000,0.250000000000000,0.250000000000000,-0.250000000000000,-0.250000000000000,-0.250000000000000,-0.250000000000000];
end