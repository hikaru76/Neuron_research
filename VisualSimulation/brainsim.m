%% データインポート
Subname = 'Sakamoto';
dir = append(Subname, '/parameter');
I = load(fullfile(dir,'I.mat')).I;
Gain = load(fullfile(dir,'Gain.mat')).Gain;
total_num = load(fullfile(dir, 'total_num.mat')).total_num;
N_Column = total_num * 2;
p0 = load(fullfile(dir, 'p0.mat')).p0;
p50 = load(fullfile(dir, 'p50.mat')).p50;
p100 = load(fullfile(dir, 'p100.mat')).p100;
p150 = load(fullfile(dir, 'p150.mat')).p150;
p200 = load(fullfile(dir, 'p200.mat')).p200;
p250 = load(fullfile(dir, 'p250.mat')).p250;
p300 = load(fullfile(dir, 'p300.mat')).p300;
p350 = load(fullfile(dir, 'p350.mat')).p350;
p400 = load(fullfile(dir, 'p400.mat')).p400;
p450 = load(fullfile(dir, 'p450.mat')).p450;
p3257 = load(fullfile(dir, 'p3257.mat')).p3257;
p3574 = load(fullfile(dir, 'p3574.mat')).p3574;
p4052 = load(fullfile(dir, 'p4052.mat')).p4052;
% p1000 = load(fullfile(dir, 'p1000.mat')).p1000;
% p2000 = load(fullfile(dir, 'p2000.mat')).p2000;
% p3000 = load(fullfile(dir, 'p3000.mat')).p3000;
% p4000 = load(fullfile(dir, 'p4000.mat')).p4000;
% p5000 = load(fullfile(dir, 'p5000.mat')).p5000;

p50(2:2:26008) = p50(2:2:26008)/17; %他カラム間inhibitoryだけ結合確率減らす．
p100(2:2:26008) = p100(2:2:26008)/17;
p150(2:2:26008) = p150(2:2:26008)/17;
p200(2:2:26008) = p200(2:2:26008)/17;
p250(2:2:26008) = p250(2:2:26008)/17;
p300(2:2:26008) = p300(2:2:26008)/17;
p350(2:2:26008) = p350(2:2:26008)/17;
p400(2:2:26008) = p400(2:2:26008)/17;
p450(2:2:26008) = p450(2:2:26008)/17;
p3257(2:2:26008) = p3257(2:2:26008)/17;
p3574(2:2:26008) = p3574(2:2:26008)/17;
p4052(2:2:26008) = p4052(2:2:26008)/17;

%% 電流設定
for i=1:total_num
    I(2*i) = I(2*i-1)*1; %流入電流比exc/inh
end
I_duration = 100000;
I_ratio = 1;
I_Delta = 1;

I = I*I_ratio;
Delta = I*I_Delta;
Delta = Delta/pi;
I_const = repmat([0.8;0.5], [total_num,1]);
Delta_const = repmat([0.2;0.4],[total_num,1])/pi;
% I_const = repmat([1;1], [total_num,1]);
% Delta_const = repmat([1;1],[total_num,1])/pi;

%% 定常電流ありにしたいならコメントアウト
I_const = I;
Delta_const = Delta;
I = I*0;
Delta = Delta*0;

%% 各定数設定
time = 100;
dt = 0.01;
step_all = time/dt;
V_rest = -62;
V_thr = -55;
tau_max = 4052; % シナプス結合による結合を入れるなら変わる。
V = sparse(repmat([0;-70], [total_num, 1]));
g_L = sparse(repmat([0.08;0.1], [total_num, 1]));
tau_d = sparse(repmat([2, 5], [1, total_num]));

r = sparse(zeros(N_Column, tau_max+1));
v = sparse(-70*ones(N_Column, 1));
g = sparse(N_Column, N_Column);
% memo_r = zeros(N_Column, step_all/10+1);
% memo_v = zeros(N_Column, step_all/10+1);
memo_r = zeros(N_Column, step_all);
memo_v = zeros(N_Column, step_all);
% memo_g = zeros(N_Column, step_all);
% memo_g2 = zeros(N_Column, step_all);

a = g_L/(V_thr-V_rest);
b1 = -g_L*(V_thr+V_rest)/(V_thr-V_rest);
c1 = g_L*V_thr*V_rest/(V_thr-V_rest);
abort = 0;

%% 計算フェーズ
for t = tau_max+1:step_all
	if t==tau_max+1+I_duration
		I_const = 0;
		Delta_const = 0;
	end
	if mod(t,100)==0
		disp(t)
    end

	b = b1-sum(g,2);
	c = c1+g*V;
	r(:,mod(t+1, tau_max)+1) = r(:,mod(t, tau_max)+1)+(2*a.*r(:,mod(t, tau_max)+1).*v+b.*r(:,mod(t, tau_max)+1)+a.*(Delta+Delta_const))*dt;
	v = v+(a.*v.*v-pi^2*r(:,mod(t, tau_max)+1).*r(:,mod(t, tau_max)+1)./a+b.*v+c+I+I_const)*dt;
	if anynan(v)
		abort = 1;
		disp(append('v comes NaN. I_ratio is ', num2str(I_ratio), '. t=', num2str(t)));
		break
    end
    g = g+(-g./tau_d+p0.*r(:,mod(t-0,tau_max)+1).'+p50.*r(:,mod(t-50,tau_max)+1).'+p100.*r(:,mod(t-100,tau_max)+1).'+p150.*r(:,mod(t-150,tau_max)+1).'+p200.*r(:,mod(t-200,tau_max)+1).'+p250.*r(:,mod(t-250,tau_max)+1).'+p200.*r(:,mod(t-200,tau_max)+1).'+p250.*r(:,mod(t-250,tau_max)+1).'+p300.*r(:,mod(t-300,tau_max)+1).'+p350.*r(:,mod(t-350,tau_max)+1).'+p400.*r(:,mod(t-400,tau_max)+1).'+p450.*r(:,mod(t-450,tau_max)+1).'+p3257.*r(:,mod(t-3257,tau_max)+1).'+p3574.*r(:,mod(t-3574,tau_max)+1).'+p4052.*r(:,mod(t-4052,tau_max)+1).')*dt;
%     g = g+(-g./tau_d+p0.*r(:,mod(t-0,tau_max)+1).'+p50.*r(:,mod(t-50,tau_max)+1).')*dt;
%     if mod(t,10)==0
%         memo_r(:,t/10) = r(:,mod(t/10, tau_max)+1);
% 	    memo_v(:,t/10) = v(:);
%     end
    memo_r(:,t) = r(:,mod(t, tau_max)+1);
	memo_v(:,t) = v(:);
% 	memo_g(:,t) = sum(g,2);
% 	memo_g2(:,t) = sum(g,1);
end

%% MEG順問題(発火率を利用して)
% sensor_output = Gain * memo_r(1:2:N_Column,:);
% 
% f1 = figure();
% hold on
% for i = 1:size(sensor_output,1)
% 	plot(sensor_output(i,tau_max+1:step_all))
% 	xlim([0,step_all])
% 	colororder('black')
% end
% hold off

%% 描画
f2 = figure();
for i = 0:10000:N_Column
    subplot(3,1,1+round(i/10000))
    plot(memo_r(1+i,:))
    title(['r(',num2str(1+i),'):E:blue,I:orange'])
    xlim([0,step_all])
    hold on
    subplot(3,1,1+round(i/10000))
    plot(memo_r(2+i,:))
    hold off
end

% f3 = figure();
% for i = 0:10000:N_Column
%     subplot(3,1,1+round(i/10000))
%     plot(memo_v(1+i,:))
%     title(['v(',num2str(1+i),'):E:blue,I:orange'])
%     xlim([0,step_all])
%     hold on
%     subplot(3,1,1+round(i/10000))
%     plot(memo_v(2+i,:))
%     hold off
% end
% f4 = figure();
% plot(memo_v(14487,tau_max+1:step_all))
% xlim([1,step_all])
% f5 = figure();
% plot(memo_r(14487,tau_max+1:step_all))
% xlim([1,step_all])
% f6 = figure();
% plot(memo_r(18415,tau_max+1:step_all))
% xlim([1,step_all])
% 
% f7 = figure();
% plot(memo_r(14487, tau_max+1:step_all))
% title('r:E:blue,I:orange')
% hold on
% plot(memo_r(14488, tau_max+1:step_all))
% hold off

%% 保存
% save('results/memo_r.mat', 'memo_r')
% save('results/memo_g.mat', 'memo_g')
% save('results/memo_g2.mat', 'memo_g2')
% save('results/memo_v.mat', 'memo_v')
% save('sensor_output.mat', 'sensor_output')

%%
% Abort = '';
% if abort == 1
%     Abort = 'Abort_';
% end
% saveas(f1, append(savedir,'/', Abort,'MEG.fig'));
% saveas(f2, append(savedir,'/', Abort,'r.fig'));
% saveas(f3, append(savedir,'/', Abort,'v.fig'));
% saveas(f4, append(savedir,'/', Abort,'v_Imax.fig'));
% saveas(f5, append(savedir,'/', Abort,'r_Imax.fig'));
% close(f1)
% close(f2)
% close(f3)
% close(f4)
% close(f5)

%% 3次元描画
r = memo_r;
r = r(1:2:size(r,1),:);
% r(1,:) = max(max(r));
r(2,:) = 0;
vertices = load("data/visual_vertices.mat").visual_vertices;
% whole = load("data/whole.mat").neuron_vertices;
% cortex = load('Sakamoto/cortex_vertices_whole_brain_high.mat').cortex;
figure()
% trisurf(cortex.Faces, cortex.Vertices(:,1), cortex.Vertices(:,2), cortex.Vertices(:,3), 'FaceColor', [0.7,0.7,0.7],'FaceAlpha', 0.4, 'LineStyle','none');
% scatter3(whole(1:100:length(whole),1), whole(1:100:length(whole),2), whole(1:100:length(whole),3), 5,[0,0,0],'filled')
% hold on
for t=tau_max+1:10:size(r,2)
   scatter3(vertices(:,1),vertices(:,2),vertices(:,3),10,r(:,t),'filled')
   daspect([1 1 1])
   txt = {append('t=',num2str(t))};
   text(-0.015,0,0.005,txt)
    text(-0.05,-0.025,0.075,txt)
   view([-20,10])
%    view([-90,90])
   colormap hot
   colorbar
   drawnow
end