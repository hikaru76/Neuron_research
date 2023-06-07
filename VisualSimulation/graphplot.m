% tau_max = 4057;
% step_all = 34000;
% 
% f7 = figure();
% plot(memo_r(14487, tau_max+1:step_all))
% hold on
% plot(memo_r(14488, tau_max+1:step_all))
% hold off
% ax = gca;
% ax.FontSize = 25;
% xlim([0 10000])
% xticks([0 2500 5000 7500 10000])
% xticklabels({'0', '25', '50','75','100'})
% xticks([tau_max+1 (tau_max+1+step_all)/2 step_all])
% xticklabels({'0', num2str((step_all-tau_max-1)/100/2), num2str((step_all-tau_max-1)/100)})
% xlabel('t (ms)') 
% ylabel('r') 
% f7.Position = [100 100 800 400];

%%
% V = sparse(repmat([0;-70], [total_num, 15000]));
% I = memo_g.*(memo_v-V);
% sensor_output = Gain * I(1:2:26008,:);
% f7 = figure();
% % a=bandpass(sensor_output(16,:), [0.1 30], 256);
% % a=bandpass(a, [0.1 100], 256);
% % plot(a(tau_max+1:14000))
% plot(sensor_output(18,tau_max+1:14000));
% ax = gca;
% ax.FontSize = 25;
% xlim([0 10000])
% xticks([0 2500 5000 7500 10000])
% xticklabels({'0', '25', '50','75','100'})
% % yticks([-20 0 20 40 60])
% % yticklabels({'-2', '0', '2', '4', '6'})
% % xticks([tau_max+1 (tau_max+1+step_all)/2 step_all])
% % xticklabels({'0', num2str((step_all-tau_max-1)/100/2), num2str((step_all-tau_max-1)/100)})
% xlabel('t (ms)') 
% ylabel('\muV') 
% f7.Position = [100 100 800 400];

%%
% r = load(append('1/memo_r.mat')).memo_r;
% r = r(1:2:size(r,1),:);
% r(1,:) = max(max(r));
r1 = memo_r(1:2:size(memo_r,1),:);
r1(1,:) = 0;
vertices = load("data/visual_vertices.mat").visual_vertices;
for t=tau_max+10-2+80:100:tau_max+10-2+80+1700
	f=figure();
	scatter3(vertices(:,1),vertices(:,2),vertices(:,3),10,r1(:,t),'filled')
	daspect([1 1 1])
	txt = {append('t=',num2str((t-tau_max-1)/100))};
	text(-0.040,0,0.015,txt, "FontSize", 30)
	view([0,0])
	colormap hot
	ax = gca;
	ax.XGrid = 'off';
	ax.YGrid = 'off';
	ax.ZGrid = 'off';
	ax.XAxis.Visible = 'off';
	ax.YAxis.Visible = 'off';
	ax.ZAxis.Visible = 'off';
% 	saveas(f, append(num2str(t),'.jpg'))
end