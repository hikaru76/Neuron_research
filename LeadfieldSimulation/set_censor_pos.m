% 皮質中央から頭皮に向かって等分した座標上にセンサを置く。センサポジションを作成する。
% EEGの場合，ricoh_channelに関する部分をコメントアウトして実行し，sensor_position変数をエクセルやvscodeでpos形式に保存
% 各種パラメータは各人で適宜調整
% argumentを自分で保存
subname = 'Sugino';
head_mask = load(fullfile(subname, 'tess_head_mask.mat')).Vertices;
cortex = load(fullfile(subname, '15002/tess_cortex_pial.mat'));
ricoh_channels = load(fullfile(subname, "channel_ricoh_acc1.mat")).Channel;
ricoh_channel = read_channel(ricoh_channels);

%%
%球を若干拡大して内側にめり込む部分がないようにする。
r=(cortex.Reg.Sphere.Vertices(1,1)^2+cortex.Reg.Sphere.Vertices(1,2)^2+cortex.Reg.Sphere.Vertices(1,3)^2)^0.5;
theta_split=40;	%2189個→60,60 1066→40,40
phi_split=40;
translation = 0.04;
sensor_position = [];
argument = [];
for phi=0:pi/phi_split:pi
		if phi==0
			sensor_position = [sensor_position; 0, 0, r*cos(phi)+translation];
			argument = [argument; 0, phi];
		else
			for theta=0:2*pi/theta_split:2*pi
				if threshold(r*sin(phi)*cos(theta), r*sin(phi)*sin(theta), r*cos(phi)+translation)==0
					sensor_position = [sensor_position; r*sin(phi)*cos(theta), r*sin(phi)*sin(theta), r*cos(phi)+translation];
					argument = [argument; theta, phi];
				end
			end
		end
end

%% 長さ調節
[k, dist] = dsearchn(head_mask, sensor_position);
% sensor_position = sensor_position / r .* (r-dist+0.001+sensor_position(:,3)*0.02); %EEG
sensor_position = sensor_position / r .* (r-dist+0.025+abs(sensor_position(:,1)*0.09)-abs(sensor_position(:,3)*0.01)); %MEG

%% 耳の部分削除 （微妙なのでやめる。)
% tmp = [];
% for i=1:length(sensor_position)
% 	if sensor_position(i,2)>-0.086
% 		tmp = [tmp; sensor_position(i,:)];
% 	end
% end
% sensor_position = tmp;

%%
figure()
% trimesh(Faces, Vertices(:,1), Vertices(:,2), Vertices(:,3));
scatter3(cortex.Vertices(1:100:length(cortex.Vertices),1),cortex.Vertices(1:100:length(cortex.Vertices),2),cortex.Vertices(1:100:length(cortex.Vertices),3),3,[1,0.4,0.4],'filled');
hold on
% scatter3(cortex.Reg.Sphere.Vertices(1:100:300000,1), cortex.Reg.Sphere.Vertices(1:100:300000,2), cortex.Reg.Sphere.Vertices(1:100:300000,3), 1, [0.7,1.0,0.7]);
scatter3(head_mask(:,1), head_mask(:,2), head_mask(:,3), 3, [0.7, 0.7, 0.7]);
scatter3(sensor_position(:,1), sensor_position(:,2), sensor_position(:,3), 10, [0.4,0.4,1],'filled');
scatter3(ricoh_channel(:,1), ricoh_channel(:,2), ricoh_channel(:,3), 10, [1, 0, 0.8], 'filled');
daspect([1,1,1])
hold off


% function tmp = threshold(x,y,z)	%2189
% 	a = 0.017523175141078*x+(2.47885982812e-4*y)+(-0.018074696311807*z)+(-8.8190394097056e-4);
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

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

% function tmp = threshold(x,y,z)		%1066
% 	a = -(-0.01158911309932*x+(9.3228169725e-4*y)+(0.012577867565765*z)+(8.98344929003773e-4));
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

function tmp = threshold(x,y,z)		%1066
	a = -(0.007212559335065*x+(0.003703521874533*y)+(0.038128161774947*z)+(7.8989370868026E-4));
	if a > 0
		tmp = 1;
	else
		tmp = 0;
	end
end

% function tmp = threshold(x,y,z)		%1177
% 	a = 0.01150205118032*x+(-0.001344218466*y)+(-0.0304011525984*z)+(-0.0025083998783022);
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

% function tmp = threshold(x,y,z)		%sugino
% 	a = -(0.010893572877983	*x+(-0.0010000471299502*y)+(0.037268807793451*z)+(1.502521783511e-4));
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

% function tmp = threshold(x,y,z)		%suginoEEG
% 	a = -(-0.0052785662517038*x+(6.7562240735344E-5*y)+(0.022364902790392*z)+(-6.8457334602035E-4));
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

% function tmp = threshold(x,y,z)		%mori
% 	a = (-0.01344935986605*x+(-0.00288536757797*y)+(-0.036472886869735*z)+(-6.2807849517669E-4));
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

% function tmp = threshold(x,y,z)		%moriEEG
% 	a = -(-0.0068973014927238*x+(-7.4265990994009E-4*y)+(0.01974004572796*z)+(-3.2042864576075E-4));
% 	if a > 0
% 		tmp = 1;
% 	else
% 		tmp = 0;
% 	end
% end

function out = read_orient(k, direction)
	tmp = [];
	for i=1:length(k)
		tmp = [tmp; direction(k(i), :)];
	end
	out = tmp;
end