%% makesourcemodel.mの実行後に用いる。 bold値をbrainstormのcortexの各頂点に乗せる。
%pos_bs:boldの位置
%cortex.Vertices:細胞集団頂点
%LeadfieldSimulationの時にはbold_on_verticeをbold_on_vertice_****,plot_vertice_numをscout_vertice_****と保存すればよい。
% save_ = 1;
% vert_num = '15002';
% megeeg = 'MEG';
if select==1
	txt = 'upper';
elseif select==2
	txt = 'lower';
elseif select==3
	txt = 'ul';
end
num_point = 10;
vertice = cortex.Vertices;
bold_on_vertice = zeros(length(vertice),1);
len_list = ones(length(vertice), length(bold));

for i=1:length(pos_bs)
	len_list(:,i) = (vertice(:,1)-pos_bs(i,1)).^2+(vertice(:,2)-pos_bs(i,2)).^2+(vertice(:,3)-pos_bs(i,3)).^2;
end

[min_distance_list, min_distance_id] = mink(len_list, num_point, 1);

plot_vertice_num = [];
for i=1:length(bold)
	for j=1:num_point
		if min_distance_list(j,i) < 2.0e-05
			bold_on_vertice(min_distance_id(j,i)) = max(bold_on_vertice(min_distance_id(j,i)), bold(i));
			if bold_on_vertice(min_distance_id(j,i))>0
				plot_vertice_num = [plot_vertice_num;min_distance_id(j,i)];
			end
		end
	end
end
if save_ == 1
	save(append(Subname, '/', vert_num, '/', megeeg, '/bold_on_vertice_', txt, '.mat'), "bold_on_vertice")
	save(append(Subname, '/', vert_num, '/', megeeg, '/scout_vertice_', txt, '.mat'), "plot_vertice_num")
end

%%
% figure()
% bold_on_vertice_color = bold_on_vertice/max(max(bold_on_vertice));
% % scatter3(cortex.Vertices(1:100:length(cortex.Vertices),1),cortex.Vertices(1:100:length(cortex.Vertices),2),cortex.Vertices(1:100:length(cortex.Vertices),3),10,[0.4,0.4,0.4]);
% scatter3(cortex.Vertices(:,1),cortex.Vertices(:,2),cortex.Vertices(:,3),10,[0.4,0.4,0.4]);
% hold on
% scatter3(pos_bs(:,1),pos_bs(:,2),pos_bs(:,3),10,[1,0,0],'filled')
% scatter3(vertice(plot_vertice_num,1), vertice(plot_vertice_num,2), vertice(plot_vertice_num,3),10,[0,1,0],'filled');
% daspect([1,1,1]);
% hold off