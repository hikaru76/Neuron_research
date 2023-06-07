% Subname = 'Mori';
% megeeg='EEG';
% solver='L1QP'; % ISDA, L1QP
% want = 8;
% apart = 'discriminant';
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
if strcmp(megeeg,'MEG')
	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_MEG;
	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_100.mat')).noise_censor_MEG;
	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_MEG;
	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_100.mat')).noise_censor_MEG;
	argument = load(append(Subname, '/15002/', megeeg, '/argument.mat')).argument;
elseif strcmp(megeeg,'EEG')
	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_EEG;
	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_100.mat')).noise_censor_EEG;
	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_EEG;
	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_100.mat')).noise_censor_EEG;
	argument = load(append(Subname, '/15002/', megeeg, '/argument.mat')).argument;
end
[idx,C] = kmeans([argument], 50);
args = [argument, [1:length(argument)].'];
censors_pos = load(append(Subname, '/15002/', megeeg, '_channel_', sens_num,'.mat')).Channel;
vertice = load(append(Subname, '/15002/tess_cortex_pial.mat')).Vertices;
if strcmp(megeeg, 'EEG')
	censor_pos = read_censors(censors_pos);
else
	censor_pos = read_channel(censors_pos);
end
full_censor_pos = censor_pos;
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
selected_sens_pos = [];
selected_sens_num = [];
for i=1:want
	if strcmp(apart, "svm")
		SVMModel = fitcsvm(X,y,"Solver",solver);
		beta = SVMModel.Beta;
	else
		SVMModel = fitcdiscr(X,y);
		beta = SVMModel.DeltaPredictor.';
	end
% 	[M,I] = max(abs(beta));
	[M,I] = min(abs(beta));

	selected_sens_pos = [selected_sens_pos; censor_pos(I,:)];
	selected_sens_num = [selected_sens_num; I];
	
	tmpx = [];
	tmpidx = [];
	tmppos = [];
	for j=1:size(X,2)
		if idx(j) ~= idx(I)
			tmpx = [tmpx, X(:,j)];
			tmppos = [tmppos; censor_pos(j,:)];
			tmpidx = [tmpidx; idx(j)];
		end
	end
	X = tmpx;
	censor_pos = tmppos;
	idx = tmpidx;
end
%%
% head_mask = load(fullfile(Subname, 'tess_head_mask.mat')).Vertices;
% s = [];
% for i=1:length(idx)
% 	if idx(i)==20
% 		s = [s;full_censor_pos(i,:)];
% 	end
% end
% figure()
% scatter3(vertice(1:1:length(vertice), 1), vertice(1:1:length(vertice), 2), vertice(1:1:length(vertice), 3), 4,[0.4,0.4,0.4], 'filled');
% hold on
% scatter3(head_mask(:,1), head_mask(:,2), head_mask(:,3), 3, [0.7, 0.7, 0.7]);
% % scatter3(full_censor_pos(:,1), full_censor_pos(:,2), full_censor_pos(:,3), 5, [1, 0.7, 0.7], 'filled');
% scatter3(selected_sens_pos(:,1), selected_sens_pos(:,2), selected_sens_pos(:,3), 40, [1, 0, 0], 'filled');
% % scatter3(s(:,1), s(:,2), s(:,3), 10, ["yellow"], "filled");
% daspect([1 1 1])
% hold off
% view([-120, 20])


%%
% head = load(fullfile(Subname, 'tess_head_mask.mat'));
% cortex = load(fullfile(Subname, '/15002/tess_cortex_pial.mat'));
% f1=figure();
% trisurf(head.Faces, head.Vertices(:,1), head.Vertices(:,2), head.Vertices(:,3), 'FaceColor', [0.7,0.7,0.7], 'FaceAlpha', 0.4, 'LineStyle','none');
% hold on
% scatter3(selected_sens_pos(:,1), selected_sens_pos(:,2), selected_sens_pos(:,3), 40, [1, 0, 0], 'filled');
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
% saveas(f1, append(megeeg, '_', Subname, '_kmean_', apart,'1.jpg'))
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
% saveas(f2, append(megeeg, '_', Subname, '_keman_', apart,'2.jpg'))
% close(f2)

%%
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