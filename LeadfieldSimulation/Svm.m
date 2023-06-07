% センサ二値分類をかけていく。measure2sim.m実行後に実行。
% Subname = 'Sakamoto';
% megeeg='MEG';
% solver = 'L1QP';
% want = 8;
% apart = "discriminant"; 
% if strcmp(Subname, 'Sakamoto')
% 	if strcmp(megeeg, 'MEG')
% 		sens_num = '1139';
% 	else
% 		sens_num = '899';
% 	end
% elseif strcmp(Subname, 'Sugino')
% 	if strcmp(megeeg, 'MEG')
% 		sens_num = '1093';
% 	else
% 		sens_num = '882';
% 	end
% elseif strcmp(Subname, 'Mori')
% 	if strcmp(megeeg, 'MEG')
% 		sens_num = '1154';
% 	else
% 		sens_num = '917';
% 	end
% end
% if strcmp(megeeg,'MEG')
% 	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_MEG;
% 	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_100.mat')).noise_censor_MEG;
% 	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_MEG;
% 	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_100.mat')).noise_censor_MEG;
% elseif strcmp(megeeg,'EEG')
% 	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_EEG;
% 	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_100.mat')).noise_censor_EEG;
% 	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_EEG;
% 	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_100.mat')).noise_censor_EEG;
% end

X = [censor_main_upper, censor_main_lower];
for i = 1:length(censor_noise_lower)
	X = [X, censor_noise_upper{i}];
	X = [X, censor_noise_lower{i}];
end
X = X.';
y = {};
for i = 1:length(censor_noise_lower)+1
	y{2*i-1} = 'upper';
	y{2*i} = 'lower';
end


if strcmp(apart, 'svm')
	SVMModel = fitcsvm(X,y,"Solver",solver);
	beta = SVMModel.Beta;
% 	SVMModel = fitcecoc(X,y,"Learners",apart);
% 	beta = SVMModel.BinaryLearners{1,1}.Beta;
else
	SVMModel = fitcdiscr(X,y);
	beta = SVMModel.DeltaPredictor.';
% 	beta = SVMModel.BinaryLearners{1,1}.DeltaPredictor.';
end

censors_pos = load(append(Subname, '/15002/', megeeg, '_channel_', sens_num,'.mat')).Channel;
vertice = load(append(Subname, '/15002/tess_cortex_pial.mat')).Vertices;
if strcmp(megeeg, 'EEG')
	censor_pos = read_censors(censors_pos);
else
	censor_pos = read_channel(censors_pos);
end

%% 近くの点関連の処理を行わないプロット
% want = 10;
% ba = abs(beta);
% tmp = [ba, censor_pos];
% [Y,I] = sort(tmp(:,1), 1, "descend");
% tmp1 = tmp(I,:);
% figure()
% scatter3(vertice(1:10:length(vertice), 1), vertice(1:10:length(vertice), 2), vertice(1:10:length(vertice), 3), 4,[0.9,0.9,0.9], 'filled');
% hold on
% scatter3(tmp1(1:want, 2), tmp1(1:want, 3), tmp1(1:want, 4), 10, [1,0,0], 'filled');
% scatter3(tmp1(want+1:length(tmp1),2), tmp1(want+1:length(tmp1),3), tmp1(want+1:length(tmp1),4), 5, [1, 0.7, 0.7], 'filled');
% hold off
% daspect([1 1 1])
% view([-120, 25]);

%% 近くのセンサを取り除かない
% ba = abs(beta);
% tmp = [ba, censor_pos];
% [Y,I] = sort(tmp(:,1), 1, "descend");
% tmp1 = tmp(I,:);
% selected_sens_num = I(1:want);
% % selected_sens_num = I(length(I)-want+1:length(I));

%% 近いセンサを取り除く
% want = 16;
% remove = 20;	%自身と周囲remove点のセンサを候補から取り除く。
% ba = abs(beta);
% tmp = [ba, censor_pos,[1:length(ba)].'];
% [Y,I] = sort(tmp(:,1), 1, "descend");
% tmp1 = tmp(I,:);
% tmp = tmp1;
% value = tmp1(:,1);
% pos = tmp1(:, 2:4);
% i = 1;
% lis = [];
% while (i <= want)
% 	lis = [lis; tmp(1,:)];
% 	distance = zeros(length(tmp),1);
% 	for j=1:length(tmp)
% 		distance(j) = ((tmp(1,2)-tmp(j,2))^2+(tmp(1,3)-tmp(j,3))^2+(tmp(1,4)-tmp(j,4))^2)^0.5;
% 	end
% 	temporal = [tmp, distance];
% 	[Y,I] = sort(temporal(:,5), 1, "ascend");
% 	temporal = temporal(I,:);
% 	tmp = temporal(remove+1:length(temporal), 1:4);
% 	[Y,I] = sort(tmp(:,1), 1, "descend");
% 	tmp = tmp(I,:);
% 	i = i+1;
% end

%% 別バージョン(個数依存ではなく距離依存で数を減らす。)
ba = abs(beta);
tmp = [ba, censor_pos,[1:length(ba)].'];
[Y,I] = sort(tmp(:,1), 1, "ascend");
tmp1 = tmp(I,:);
tmp = tmp1;
value = tmp1(:,1);
pos = tmp1(:, 2:4);
i = 1;
lis = [];
while (i <= want)
	lis = [lis; tmp(1,:)];
	temporal = [];
	for j=1:length(tmp)
		if ((tmp(1,2)-tmp(j,2))^2+(tmp(1,3)-tmp(j,3))^2+(tmp(1,4)-tmp(j,4))^2)^0.5 > 0.04
			temporal = [temporal; tmp(j,:)];
		end
	end
	tmp = temporal;
	[Y,I] = sort(tmp(:,1), 1, "ascend");
	tmp = tmp(I,:);
	i = i+1;
end
selected_sens_num = lis(:,5);

%% 近くの点関連の処理を行うプロット
% head_mask = load(fullfile(Subname, 'tess_head_mask.mat')).Vertices;
% figure()
% scatter3(vertice(1:1:length(vertice), 1), vertice(1:1:length(vertice), 2), vertice(1:1:length(vertice), 3), 4,[0.4,0.4,0.4], 'filled');
% hold on
% scatter3(head_mask(:,1), head_mask(:,2), head_mask(:,3), 3, [0.7, 0.7, 0.7]);
% % scatter3(sim_channel(min_distance_id(1:160),1), sim_channel(min_distance_id(1:160),2), sim_channel(min_distance_id(1:160),3),10,[0.4,0.4,1],'filled');
% % scatter3(pos(:,1), pos(:,2), pos(:,3), 5, [1, 0.7, 0.7], 'filled');
% scatter3(censor_pos(selected_sens_num,1), censor_pos(selected_sens_num,2), censor_pos(selected_sens_num,3), 15, [1,0,0], 'filled');
% hold off
% daspect([1 1 1])
% view([-120, 20])

% head = load(fullfile(Subname, 'tess_head_mask.mat'));
% cortex = load(fullfile(Subname, '/15002/tess_cortex_pial.mat'));
% f1=figure();
% trisurf(head.Faces, head.Vertices(:,1), head.Vertices(:,2), head.Vertices(:,3), 'FaceColor', [0.7,0.7,0.7], 'FaceAlpha', 0.4, 'LineStyle','none');
% hold on
% scatter3(censor_pos(selected_sens_num,1), censor_pos(selected_sens_num,2), censor_pos(selected_sens_num,3), 40, [1,0,0], 'filled');
% trisurf(cortex.Faces, cortex.Vertices(:,1), cortex.Vertices(:,2), cortex.Vertices(:,3), 'FaceColor', [0.3,0.3,0.3],'LineStyle','none');
% daspect([1 1 1])
% view([-90, 90])
% ax = gca;
% ax.XTickLabel = [];
% ax.YTickLabel = [];
% ax.ZTickLabel = [];
% ax.XAxis.Visible = 'off';
% ax.YAxis.Visible = 'off';
% ax.ZAxis.Visible = 'off';
% ax.XGrid = 'off';
% ax.YGrid = 'off';
% ax.ZGrid = 'off';
% saveas(f1, append(megeeg, '_', Subname, '_SVM_', apart,'1.jpg'))
% close(f1)

% f2=figure();
% trisurf(head.Faces, head.Vertices(:,1), head.Vertices(:,2), head.Vertices(:,3), 'FaceColor', [0.7,0.7,0.7], 'FaceAlpha', 0.4, 'LineStyle','none');
% hold on
% scatter3(selected_sens_pos(:,1), selected_sens_pos(:,2), selected_sens_pos(:,3), 40, [1, 0, 0], 'filled');
% trisurf(cortex.Faces, cortex.Vertices(:,1), cortex.Vertices(:,2), cortex.Vertices(:,3), 'FaceColor', [0.3,0.3,0.3],'LineStyle','none');
% daspect([1 1 1])
% view([-130, 25])
% ax = gca;
% ax.XTickLabel = [];
% ax.YTickLabel = [];
% ax.ZTickLabel = [];
% ax.XAxis.Visible = 'off';
% ax.YAxis.Visible = 'off';
% ax.ZAxis.Visible = 'off';
% ax.XGrid = 'off';
% ax.YGrid = 'off';
% ax.ZGrid = 'off';
% saveas(f2, append(megeeg, '_', Subname, '_SVM_', apart,'2.jpg'))
% close(f2)

function a = read_censors(c)
	tmp = [];
	for i = 1:length(c)
		tmp = [tmp; c(i).Loc.'];
	end
	a = tmp;
end

function out = read_channel(channel)
	tmp = [];
	for i = 1:length(channel)
		if length(channel(i).Loc) == 8
			tm = mean(channel(i).Loc(:,1:4), 2);
			tmp = cat(1, tmp, [tm(1), tm(2), tm(3)]);
		else
			tmp = cat(1, tmp, [0, 0, 0]);
		end
	end
	out = tmp;
end