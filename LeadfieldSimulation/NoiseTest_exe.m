% Subname = 'Mori';
% megeeg='EEG';
% num_noise = '100';
% num_test = 100; %テストケースを何個入れるか：100 or 1000
% want = 20; % センサ数何個に減らすか 8,16,32
% 
% sn = 30;
% solver='L1QP'; % ISDA, L1QP, SMO kmeansセンサ最適化でどのSVMsolverを用いるか
% select_noise = 1; % 0:ノイズなし 1:ホワイトガウスノイズ, 2:上下反対の値, 3:両方
% ratio = 0; % 上下反対の値の割合。0-1
% ratio_ul = 0; % テストケースにupper&lowerを入れる割合。0-1
% learn_ul = 1; % upper&lowerを学習させるか。0or1
% others = 1; % 完全なるランダム値（他の領野が働いていると仮定）を学習させるか 0or1

filename = append('SimNoiseTest_', num2str(sn),'_',num2str(want), '.xlsx');
disp(filename)
if strcmp(Subname, 'Sugino')
	if strcmp(megeeg, 'MEG')
		sheet = 1;
	elseif strcmp(megeeg, 'EEG')
		sheet = 2;
	end
elseif strcmp(Subname, 'Mori')
	if strcmp(megeeg, 'MEG')
		sheet = 3;
	elseif strcmp(megeeg, 'EEG')
		sheet = 4;
	end
elseif strcmp(Subname, 'Sakamoto')
	if strcmp(megeeg, 'MEG')
		sheet = 5;
	elseif strcmp(megeeg, 'EEG')
		sheet = 6;
	end
end
writematrix("no reduction", filename, 'Sheet', sheet, 'Range', 'A1');
writematrix("kmeans", filename, 'Sheet', sheet, 'Range', 'O1');
writematrix("SVM", filename, 'Sheet', sheet, 'Range', 'AC1');

tic
for reduction=3:3 %0-3
	for normal=0:0
		for ap=1:2
			if reduction==0 && ap==2
				continue
			end
			switch reduction
				case 3 %減らさないバージョンをなくした。
					switch normal
						case 0
							wrcell = 'A';
						case 1
							wrcell = 'H';
					end
				case 1
					switch normal
						case 0
							wrcell = 'O';
						case 1
							wrcell = 'V';
					end
				case 2
					switch normal
						case 0
							wrcell = 'AC';
						case 1
							wrcell = 'AJ';
					end
			end
			if ap==1
				apart = 'svm';
				wrcell = append(wrcell, '2');
			else
				apart = 'discriminant';
				wrcell = append(wrcell, '12');
			end
			NoiseTest;
			writecell(output,filename,'Sheet',sheet,'Range', wrcell);
			if reduction==1
				if ap==1
					writematrix(output2,filename,'Sheet',sheet, 'Range','U3');
				else
					writematrix(output2,filename,'Sheet',sheet, 'Range','U13');
				end
			elseif reduction==2
				if ap==1
					writematrix(output2,filename,'Sheet',sheet, 'Range','AI3');
				else
					writematrix(output2,filename,'Sheet',sheet, 'Range','AI13');
				end
			elseif reduction==3
				if ap==1
					writematrix(output2,filename,'Sheet',sheet, 'Range','G3');
				else
					writematrix(output2,filename,'Sheet',sheet, 'Range','G13');
				end
			end
		end
	end
end
toc