% Simulationデータだけを用いてノイズに対するロバスト性の検証
% Subname = 'Sugino';
% megeeg='EEG';
% num_noise = '100';
% num_test = 1000; %テストケースを何個入れるか：100 or 1000
% solver='L1QP'; % ISDA, L1QP, kmeansセンサ最適化でどのSVMsolverを用いるか
% want = 8; % センサ数何個に減らすか 8,16,32
% reduction = 1; % 0:減らさない, 1:kmeans, 2:SVM
% normal = 0; % 1:正規化, 0:しない
% apart = 'discriminant'; % svm, discriminant
% 
% select_noise = 3; % 0:ノイズなし 1:ホワイトガウスノイズ, 2:上下反対の値, 3:両方
% sn = 15; % ホワイトガウスノイズ:SN比
% ratio = 0.2; % 上下反対の値の割合。0-1
% ratio_ul = 0; % テストケースにupper&lowerを入れる割合。0-1
% learn_ul = 1; % upper&lowerを学習させるか。0or1
% others = 1; % 完全なるランダム値（他の領野が働いていると仮定）を学習させるか 0or1
rng(1234); % ホワイトガウスノイズシード固定

if strcmp(Subname, 'Sakamoto')
	if strcmp(megeeg, 'MEG')
		sens_num = '1139';
	else
		sens_num = '899';
	end
elseif strcmp(Subname, 'Sugino')
	if strcmp(megeeg, 'MEG')
		sens_num = '1093';
	else
		sens_num = '882';
	end
elseif strcmp(Subname, 'Mori')
	if strcmp(megeeg, 'MEG')
		sens_num = '1154';
	else
		sens_num = '917';
	end
end

if strcmp(megeeg,'MEG')
	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_MEG;
	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_MEG;
	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_MEG;
	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_MEG;
	test_sens_upper = load(append(Subname, '/15002/', megeeg, '/upper_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_MEG;
	test_sens_lower = load(append(Subname, '/15002/', megeeg, '/lower_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_MEG;
	if learn_ul == 1
	censor_main_ul = load(append(Subname, '/15002/', megeeg, '/ul_',sens_num,'/censor_main.mat')).censor_output_MEG;
	censor_noise_ul = load(append(Subname, '/15002/', megeeg, '/ul_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_MEG;
	test_sens_ul = load(append(Subname, '/15002/', megeeg, '/ul_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_MEG;
	end
	if others == 1
		censor_others = load(append(Subname, '/15002/', megeeg, '/others/censor_others.mat')).censor_output_MEG;
	end
elseif strcmp(megeeg,'EEG')
	censor_main_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_main.mat')).censor_output_EEG;
	censor_noise_upper = load(append(Subname, '/15002/', megeeg, '/upper_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_EEG;
	censor_main_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_main.mat')).censor_output_EEG;
	censor_noise_lower = load(append(Subname, '/15002/', megeeg, '/lower_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_EEG;
	test_sens_upper = load(append(Subname, '/15002/', megeeg, '/upper_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_EEG;
	test_sens_lower = load(append(Subname, '/15002/', megeeg, '/lower_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_EEG;
	if learn_ul == 1
		censor_main_ul = load(append(Subname, '/15002/', megeeg, '/ul_',sens_num,'/censor_main.mat')).censor_output_EEG;
		censor_noise_ul = load(append(Subname, '/15002/', megeeg, '/ul_',sens_num,'/censor_noise_', num_noise, '.mat')).noise_censor_EEG;
		test_sens_ul = load(append(Subname, '/15002/', megeeg, '/ul_', sens_num,'/test_censor_noise_', num2str(num_test), '.mat')).noise_censor_EEG;
	end
	if others == 1
		censor_others = load(append(Subname, '/15002/', megeeg, '/others/censor_others.mat')).censor_output_EEG;
	end
end
%%
if select_noise == 1 % 1:ホワイトガウスノイズ
	for i=1:length(test_sens_upper)
		test_sens_upper{i} = awgn(test_sens_upper{i}, sn);
		test_sens_lower{i} = awgn(test_sens_lower{i}, sn);
	end
elseif select_noise == 2 % 2:上下反対の値
	for i=1:length(test_sens_upper)
		tmp_upper = test_sens_upper{i};
		tmp_lower = test_sens_lower{i};
		test_sens_upper{i} = test_sens_upper{i} * (1-ratio-ratio_ul) + tmp_lower * ratio + test_sens_ul{i} * ratio_ul;
		test_sens_lower{i} = test_sens_lower{i} * (1-ratio-ratio_ul) + tmp_upper * ratio + test_sens_ul{i} * ratio_ul;
	end
elseif select_noise == 3 % 3:両方
	for i=1:length(test_sens_upper)
		tmp_upper = test_sens_upper{i};
		tmp_lower = test_sens_lower{i};
		test_sens_upper{i} = test_sens_upper{i} * (1-ratio-ratio_ul) + tmp_lower * ratio + test_sens_ul{i} * ratio_ul;
		test_sens_lower{i} = test_sens_lower{i} * (1-ratio-ratio_ul) + tmp_upper * ratio + test_sens_ul{i} * ratio_ul;
		test_sens_upper{i} = awgn(test_sens_upper{i}, sn);
		test_sens_lower{i} = awgn(test_sens_lower{i}, sn);
	end
end

%% センサ数全部での検証
if reduction == 0
	if normal == 1 %正規化
		censor_main_upper = normalize(censor_main_upper, 'zscore');
		censor_main_lower = normalize(censor_main_lower, 'zscore');
		censor_main_ul = normalize(censor_main_ul, 'zscore');
		for i=1:length(censor_noise_lower)
			censor_noise_upper{i} = normalize(censor_noise_upper{i}, 'zscore');
			censor_noise_lower{i} = normalize(censor_noise_lower{i}, 'zscore');
			censor_noise_ul{i} = normalize(censor_noise_ul{i}, 'zscore');
			test_sens_upper{i} = normalize(test_sens_upper{i}, 'zscore');
			test_sens_lower{i} = normalize(test_sens_lower{i}, 'zscore');
		end
		for i=1:size(censor_others, 2)
			censor_others(:,i) = normalize(censor_others(:,i), 'zscore');
		end
	end
	X = [censor_main_upper, censor_main_lower];
	for i = 1:size(censor_noise_upper,2)
		X = [X, censor_noise_upper{i}];
		X = [X, censor_noise_lower{i}];
	end
	Y = [];
	for i = 1:size(censor_noise_upper,2)+1
		Y = [Y; 1; 0];
	end
	if learn_ul==1
		X = [X, censor_main_ul];
		for i = 1:length(censor_noise_ul)
			X = [X, censor_noise_ul{i}];
		end
		Y = [Y; 2*ones(size(censor_noise_ul,2)+1, 1)];
	end
	if others==1
		X = [X, censor_others];
		Y = [Y; 3*ones(size(censor_others,2), 1)];
	end
	X = X.';
	SVM = fitcecoc(X,Y,"Learners","svm");
	TREE = fitcecoc(X,Y,"Learners","tree");
	KNN = fitcecoc(X,Y,"Learners","knn");
	DIS = fitcecoc(X,Y,"Learners","discriminant");
	result_upper_svm = zeros(num_test, 1);
	result_lower_svm = zeros(num_test, 1);
	result_upper_tree = zeros(num_test, 1);
	result_lower_tree = zeros(num_test, 1);
	result_upper_knn = zeros(num_test, 1);
	result_lower_knn = zeros(num_test, 1);
	result_upper_dis = zeros(num_test, 1);
	result_lower_dis = zeros(num_test, 1);
	for i=1:num_test
		result_upper_svm(i) = predict(SVM, test_sens_upper{i}.');
		result_lower_svm(i) = predict(SVM, test_sens_lower{i}.');
		result_upper_tree(i) = predict(TREE, test_sens_upper{i}.');
		result_lower_tree(i) = predict(TREE, test_sens_lower{i}.');
		result_upper_knn(i) = predict(KNN, test_sens_upper{i}.');
		result_lower_knn(i) = predict(KNN, test_sens_lower{i}.');
		result_upper_dis(i) = predict(DIS, test_sens_upper{i}.');
		result_lower_dis(i) = predict(DIS, test_sens_lower{i}.');
	end
	counts = zeros(8,4);
	for i=1:num_test
		switch result_upper_svm(i)
			case 0
				counts(1,1) = counts(1,1) + 1;
			case 1
				counts(1,2) = counts(1,2) + 1;
			case 2
				counts(1,3) = counts(1,3) + 1;
			case 3
				counts(1,4) = counts(1,4) + 1;
		end
		switch result_lower_svm(i)
			case 0
				counts(2,1) = counts(2,1) + 1;
			case 1
				counts(2,2) = counts(2,2) + 1;
			case 2
				counts(2,3) = counts(2,3) + 1;
			case 3
				counts(2,4) = counts(2,4) + 1;
		end
		switch result_upper_tree(i)
			case 0
				counts(3,1) = counts(3,1) + 1;
			case 1
				counts(3,2) = counts(3,2) + 1;
			case 2
				counts(3,3) = counts(3,3) + 1;
			case 3
				counts(3,4) = counts(3,4) + 1;
		end
		switch result_lower_tree(i)
			case 0
				counts(4,1) = counts(4,1) + 1;
			case 1
				counts(4,2) = counts(4,2) + 1;
			case 2
				counts(4,3) = counts(4,3) + 1;
			case 3
				counts(4,4) = counts(4,4) + 1;
		end
		switch result_upper_knn(i)
			case 0
				counts(5,1) = counts(5,1) + 1;
			case 1
				counts(5,2) = counts(5,2) + 1;
			case 2
				counts(5,3) = counts(5,3) + 1;
			case 3
				counts(5,4) = counts(5,4) + 1;
		end
		switch result_lower_knn(i)
			case 0
				counts(6,1) = counts(6,1) + 1;
			case 1
				counts(6,2) = counts(6,2) + 1;
			case 2
				counts(6,3) = counts(6,3) + 1;
			case 3
				counts(6,4) = counts(6,4) + 1;
		end
		switch result_upper_dis(i)
			case 0
				counts(7,1) = counts(7,1) + 1;
			case 1
				counts(7,2) = counts(7,2) + 1;
			case 2
				counts(7,3) = counts(7,3) + 1;
			case 3
				counts(7,4) = counts(7,4) + 1;
		end
		switch result_lower_dis(i)
			case 0
				counts(8,1) = counts(8,1) + 1;
			case 1
				counts(8,2) = counts(8,2) + 1;
			case 2
				counts(8,3) = counts(8,3) + 1;
			case 3
				counts(8,4) = counts(8,4) + 1;
		end
	end
	output = {apart, 'lower', 'upper', 'upper&lower', 'others', 'accuracy'};
	output{2,1} = 'SVM_upper';
	output{3,1} = 'SVM_lower';
	output{4,1} = 'Tree_upper';
	output{5,1} = 'Tree_lower';
	output{6,1} = 'KNN_upper';
	output{7,1} = 'KNN_lower';
	output{8,1} = 'LDA_upper';
	output{9,1} = 'LDA_lower';
	for i=2:size(output,1)
		for j=2:size(output,2)
			if j<size(output,2)
				output{i,j} = counts(i-1, j-1);
			else
				if mod(i,2) == 0
					output{i,j} = counts(i-1, 2)/num_test;
				else
					output{i,j} = counts(i-1, 1)/num_test;
				end
			end
		end
	end
	output2 = zeros(4,1);
	output2(1) = (output{2,6}+output{3,6})/2;
	output2(2) = (output{4,6}+output{5,6})/2;
	output2(3) = (output{6,6}+output{7,6})/2;
	output2(4) = (output{8,6}+output{9,6})/2;
%% センサ数をkmeansで減らしての検証
elseif reduction == 1
	kmean;
	if normal == 1 %正規化
		censor_main_upper = normalize(censor_main_upper, 'zscore');
		censor_main_lower = normalize(censor_main_lower, 'zscore');
		if learn_ul == 1
			censor_main_ul = normalize(censor_main_ul, 'zscore');
		end
		for i=1:length(censor_noise_lower)
			censor_noise_upper{i} = normalize(censor_noise_upper{i}, 'zscore');
			censor_noise_lower{i} = normalize(censor_noise_lower{i}, 'zscore');
			if learn_ul == 1
				censor_noise_ul{i} = normalize(censor_noise_ul{i}, 'zscore');
			end
			test_sens_upper{i} = normalize(test_sens_upper{i}, 'zscore');
			test_sens_lower{i} = normalize(test_sens_lower{i}, 'zscore');
		end
		if others==1
			for i=1:size(censor_others, 2)
				censor_others(:,i) = normalize(censor_others(:,i), 'zscore');
			end
		end
	end
	selec_censor_main_upper = select_sensor(censor_main_upper, selected_sens_num);
	selec_censor_main_lower = select_sensor(censor_main_lower, selected_sens_num);
	if learn_ul==1
		selec_censor_main_ul = select_sensor(censor_main_ul, selected_sens_num);
	end
	for i=1:length(censor_noise_upper)
		selec_censor_noise_upper{i} = select_sensor(censor_noise_upper{i}, selected_sens_num);
		selec_censor_noise_lower{i} = select_sensor(censor_noise_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_censor_noise_ul{i} = select_sensor(censor_noise_ul{i}, selected_sens_num);
		end
	end
	for i=1:num_test
		selec_test_sens_upper{i} = select_sensor(test_sens_upper{i}, selected_sens_num);
		selec_test_sens_lower{i} = select_sensor(test_sens_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_test_sens_ul{i} = select_sensor(test_sens_ul{i}, selected_sens_num);
		end
	end
	if others==1
		selec_censor_others = zeros(length(selected_sens_num), size(censor_others, 2));
		for i=1:size(censor_others, 2)
			selec_censor_others(:,i) = select_sensor(censor_others(:,i), selected_sens_num);
		end
	end

	X = [selec_censor_main_upper, selec_censor_main_lower];
	for i = 1:length(selec_censor_noise_lower)
		X = [X, selec_censor_noise_upper{i}];
		X = [X, selec_censor_noise_lower{i}];
	end
	Y = [];
	for i = 1:length(selec_censor_noise_lower)+1
		Y = [Y; 1; 0];
	end
	if learn_ul==1
		X = [X, selec_censor_main_ul];
		for i = 1:length(selec_censor_noise_ul)
			X = [X, selec_censor_noise_ul{i}];
		end
		Y = [Y; 2*ones(size(selec_censor_noise_ul,2)+1, 1)];
	end
	if others==1
		X = [X, selec_censor_others];
		Y = [Y; 3*ones(size(selec_censor_others,2), 1)];
	end

	X = X.';
	SVM = fitcecoc(X,Y,"Learners","svm");
	TREE = fitcecoc(X,Y,"Learners","tree");
	KNN = fitcecoc(X,Y,"Learners","knn");
	DIS = fitcecoc(X,Y,"Learners","discriminant");
	result_upper_svm = zeros(num_test, 1);
	result_lower_svm = zeros(num_test, 1);
	result_upper_tree = zeros(num_test, 1);
	result_lower_tree = zeros(num_test, 1);
	result_upper_knn = zeros(num_test, 1);
	result_lower_knn = zeros(num_test, 1);
	result_upper_dis = zeros(num_test, 1);
	result_lower_dis = zeros(num_test, 1);
	for i=1:num_test
		result_upper_svm(i) = predict(SVM, selec_test_sens_upper{i}.');
		result_lower_svm(i) = predict(SVM, selec_test_sens_lower{i}.');
		result_upper_tree(i) = predict(TREE, selec_test_sens_upper{i}.');
		result_lower_tree(i) = predict(TREE, selec_test_sens_lower{i}.');
		result_upper_knn(i) = predict(KNN, selec_test_sens_upper{i}.');
		result_lower_knn(i) = predict(KNN, selec_test_sens_lower{i}.');
		result_upper_dis(i) = predict(DIS, selec_test_sens_upper{i}.');
		result_lower_dis(i) = predict(DIS, selec_test_sens_lower{i}.');
	end
	counts = zeros(8,4);
	for i=1:num_test
		switch result_upper_svm(i)
			case 0
				counts(1,1) = counts(1,1) + 1;
			case 1
				counts(1,2) = counts(1,2) + 1;
			case 2
				counts(1,3) = counts(1,3) + 1;
			case 3
				counts(1,4) = counts(1,4) + 1;
		end
		switch result_lower_svm(i)
			case 0
				counts(2,1) = counts(2,1) + 1;
			case 1
				counts(2,2) = counts(2,2) + 1;
			case 2
				counts(2,3) = counts(2,3) + 1;
			case 3
				counts(2,4) = counts(2,4) + 1;
		end
		switch result_upper_tree(i)
			case 0
				counts(3,1) = counts(3,1) + 1;
			case 1
				counts(3,2) = counts(3,2) + 1;
			case 2
				counts(3,3) = counts(3,3) + 1;
			case 3
				counts(3,4) = counts(3,4) + 1;
		end
		switch result_lower_tree(i)
			case 0
				counts(4,1) = counts(4,1) + 1;
			case 1
				counts(4,2) = counts(4,2) + 1;
			case 2
				counts(4,3) = counts(4,3) + 1;
			case 3
				counts(4,4) = counts(4,4) + 1;
		end
		switch result_upper_knn(i)
			case 0
				counts(5,1) = counts(5,1) + 1;
			case 1
				counts(5,2) = counts(5,2) + 1;
			case 2
				counts(5,3) = counts(5,3) + 1;
			case 3
				counts(5,4) = counts(5,4) + 1;
		end
		switch result_lower_knn(i)
			case 0
				counts(6,1) = counts(6,1) + 1;
			case 1
				counts(6,2) = counts(6,2) + 1;
			case 2
				counts(6,3) = counts(6,3) + 1;
			case 3
				counts(6,4) = counts(6,4) + 1;
		end
		switch result_upper_dis(i)
			case 0
				counts(7,1) = counts(7,1) + 1;
			case 1
				counts(7,2) = counts(7,2) + 1;
			case 2
				counts(7,3) = counts(7,3) + 1;
			case 3
				counts(7,4) = counts(7,4) + 1;
		end
		switch result_lower_dis(i)
			case 0
				counts(8,1) = counts(8,1) + 1;
			case 1
				counts(8,2) = counts(8,2) + 1;
			case 2
				counts(8,3) = counts(8,3) + 1;
			case 3
				counts(8,4) = counts(8,4) + 1;
		end
	end
	output = {apart, 'lower', 'upper', 'upper&lower', 'others', 'accuracy'};
	output{2,1} = 'SVM_upper';
	output{3,1} = 'SVM_lower';
	output{4,1} = 'Tree_upper';
	output{5,1} = 'Tree_lower';
	output{6,1} = 'KNN_upper';
	output{7,1} = 'KNN_lower';
	output{8,1} = 'LDA_upper';
	output{9,1} = 'LDA_lower';
	for i=2:size(output,1)
		for j=2:size(output,2)
			if j<size(output,2)
				output{i,j} = counts(i-1, j-1);
			else
				if mod(i,2) == 0
					output{i,j} = counts(i-1, 2)/num_test;
				else
					output{i,j} = counts(i-1, 1)/num_test;
				end
			end
		end
	end
	output2 = zeros(4,1);
	output2(1) = (output{2,6}+output{3,6})/2;
	output2(2) = (output{4,6}+output{5,6})/2;
	output2(3) = (output{6,6}+output{7,6})/2;
	output2(4) = (output{8,6}+output{9,6})/2;
%% センサ数をSVMで減らしての検証
elseif reduction == 2
	Svm;
	if normal == 1 %正規化
		censor_main_upper = normalize(censor_main_upper, 'zscore');
		censor_main_lower = normalize(censor_main_lower, 'zscore');
		if learn_ul == 1
			censor_main_ul = normalize(censor_main_ul, 'zscore');
		end
		for i=1:length(censor_noise_lower)
			censor_noise_upper{i} = normalize(censor_noise_upper{i}, 'zscore');
			censor_noise_lower{i} = normalize(censor_noise_lower{i}, 'zscore');
			if learn_ul == 1
				censor_noise_ul{i} = normalize(censor_noise_ul{i}, 'zscore');
			end
			test_sens_upper{i} = normalize(test_sens_upper{i}, 'zscore');
			test_sens_lower{i} = normalize(test_sens_lower{i}, 'zscore');
		end
		if others==1
			for i=1:size(censor_others, 2)
				censor_others(:,i) = normalize(censor_others(:,i), 'zscore');
			end
		end
	end
	selec_censor_main_upper = select_sensor(censor_main_upper, selected_sens_num);
	selec_censor_main_lower = select_sensor(censor_main_lower, selected_sens_num);
	if learn_ul == 1
		selec_censor_main_ul = select_sensor(censor_main_ul, selected_sens_num);
	end
	for i=1:length(censor_noise_upper)
		selec_censor_noise_upper{i} = select_sensor(censor_noise_upper{i}, selected_sens_num);
		selec_censor_noise_lower{i} = select_sensor(censor_noise_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_censor_noise_ul{i} = select_sensor(censor_noise_ul{i}, selected_sens_num);
		end
	end
	for i=1:num_test
		selec_test_sens_upper{i} = select_sensor(test_sens_upper{i}, selected_sens_num);
		selec_test_sens_lower{i} = select_sensor(test_sens_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_test_sens_ul{i} = select_sensor(test_sens_ul{i}, selected_sens_num);
		end
	end
	if others==1
		selec_censor_others = zeros(length(selected_sens_num), size(censor_others, 2));
		for i=1:size(censor_others, 2)
			selec_censor_others(:,i) = select_sensor(censor_others(:,i), selected_sens_num);
		end
	end

	X = [selec_censor_main_upper, selec_censor_main_lower];
	for i = 1:length(selec_censor_noise_lower)
		X = [X, selec_censor_noise_upper{i}];
		X = [X, selec_censor_noise_lower{i}];
	end
	Y = [];
	for i = 1:length(selec_censor_noise_lower)+1
		Y = [Y; 1; 0];
	end
	if learn_ul==1
		X = [X, selec_censor_main_ul];
		for i = 1:length(selec_censor_noise_ul)
			X = [X, selec_censor_noise_ul{i}];
		end
		Y = [Y; 2*ones(size(selec_censor_noise_ul,2)+1, 1)];
	end
	if others==1
		X = [X, selec_censor_others];
		Y = [Y; 3*ones(size(selec_censor_others,2), 1)];
	end

	X = X.';
	SVM = fitcecoc(X,Y,"Learners","svm");
	TREE = fitcecoc(X,Y,"Learners","tree");
	KER = fitcecoc(X,Y,'Learners','kernel');
	KNN = fitcecoc(X,Y,"Learners","knn");
	DIS = fitcecoc(X,Y,"Learners","discriminant");
	result_upper_svm = zeros(num_test, 1);
	result_lower_svm = zeros(num_test, 1);
	result_upper_tree = zeros(num_test, 1);
	result_lower_tree = zeros(num_test, 1);
	result_upper_ker = zeros(num_test, 1);
	result_lower_ker = zeros(num_test, 1);
	result_upper_knn = zeros(num_test, 1);
	result_lower_knn = zeros(num_test, 1);
	result_upper_dis = zeros(num_test, 1);
	result_lower_dis = zeros(num_test, 1);
	for i=1:num_test
		result_upper_svm(i) = predict(SVM, selec_test_sens_upper{i}.');
		result_lower_svm(i) = predict(SVM, selec_test_sens_lower{i}.');
		result_upper_tree(i) = predict(TREE, selec_test_sens_upper{i}.');
		result_lower_tree(i) = predict(TREE, selec_test_sens_lower{i}.');
		result_upper_ker(i) = predict(KER, selec_test_sens_upper{i}.');
		result_lower_ker(i) = predict(KER, selec_test_sens_lower{i}.');
		result_upper_knn(i) = predict(KNN, selec_test_sens_upper{i}.');
		result_lower_knn(i) = predict(KNN, selec_test_sens_lower{i}.');
		result_upper_dis(i) = predict(DIS, selec_test_sens_upper{i}.');
		result_lower_dis(i) = predict(DIS, selec_test_sens_lower{i}.');
	end
	counts = zeros(8,4);
	for i=1:num_test
		switch result_upper_svm(i)
			case 0
				counts(1,1) = counts(1,1) + 1;
			case 1
				counts(1,2) = counts(1,2) + 1;
			case 2
				counts(1,3) = counts(1,3) + 1;
			case 3
				counts(1,4) = counts(1,4) + 1;
		end
		switch result_lower_svm(i)
			case 0
				counts(2,1) = counts(2,1) + 1;
			case 1
				counts(2,2) = counts(2,2) + 1;
			case 2
				counts(2,3) = counts(2,3) + 1;
			case 3
				counts(2,4) = counts(2,4) + 1;
		end
		switch result_upper_tree(i)
			case 0
				counts(3,1) = counts(3,1) + 1;
			case 1
				counts(3,2) = counts(3,2) + 1;
			case 2
				counts(3,3) = counts(3,3) + 1;
			case 3
				counts(3,4) = counts(3,4) + 1;
		end
		switch result_lower_tree(i)
			case 0
				counts(4,1) = counts(4,1) + 1;
			case 1
				counts(4,2) = counts(4,2) + 1;
			case 2
				counts(4,3) = counts(4,3) + 1;
			case 3
				counts(4,4) = counts(4,4) + 1;
		end
		switch result_upper_knn(i)
			case 0
				counts(5,1) = counts(5,1) + 1;
			case 1
				counts(5,2) = counts(5,2) + 1;
			case 2
				counts(5,3) = counts(5,3) + 1;
			case 3
				counts(5,4) = counts(5,4) + 1;
		end
		switch result_lower_knn(i)
			case 0
				counts(6,1) = counts(6,1) + 1;
			case 1
				counts(6,2) = counts(6,2) + 1;
			case 2
				counts(6,3) = counts(6,3) + 1;
			case 3
				counts(6,4) = counts(6,4) + 1;
		end
		switch result_upper_dis(i)
			case 0
				counts(7,1) = counts(7,1) + 1;
			case 1
				counts(7,2) = counts(7,2) + 1;
			case 2
				counts(7,3) = counts(7,3) + 1;
			case 3
				counts(7,4) = counts(7,4) + 1;
		end
		switch result_lower_dis(i)
			case 0
				counts(8,1) = counts(8,1) + 1;
			case 1
				counts(8,2) = counts(8,2) + 1;
			case 2
				counts(8,3) = counts(8,3) + 1;
			case 3
				counts(8,4) = counts(8,4) + 1;
		end
	end
	output = {apart, 'lower', 'upper', 'upper&lower', 'others', 'accuracy'};
	output{2,1} = 'SVM_upper';
	output{3,1} = 'SVM_lower';
	output{4,1} = 'Tree_upper';
	output{5,1} = 'Tree_lower';
	output{6,1} = 'KNN_upper';
	output{7,1} = 'KNN_lower';
	output{8,1} = 'LDA_upper';
	output{9,1} = 'LDA_lower';
	for i=2:size(output,1)
		for j=2:size(output,2)
			if j<size(output,2)
				output{i,j} = counts(i-1, j-1);
			else
				if mod(i,2) == 0
					output{i,j} = counts(i-1, 2)/num_test;
				else
					output{i,j} = counts(i-1, 1)/num_test;
				end
			end
		end
	end
	output2 = zeros(4,1);
	output2(1) = (output{2,6}+output{3,6})/2;
	output2(2) = (output{4,6}+output{5,6})/2;
	output2(3) = (output{6,6}+output{7,6})/2;
	output2(4) = (output{8,6}+output{9,6})/2;
elseif reduction == 3
	nonSVM;
	if normal == 1 %正規化
		censor_main_upper = normalize(censor_main_upper, 'zscore');
		censor_main_lower = normalize(censor_main_lower, 'zscore');
		if learn_ul == 1
			censor_main_ul = normalize(censor_main_ul, 'zscore');
		end
		for i=1:length(censor_noise_lower)
			censor_noise_upper{i} = normalize(censor_noise_upper{i}, 'zscore');
			censor_noise_lower{i} = normalize(censor_noise_lower{i}, 'zscore');
			if learn_ul == 1
				censor_noise_ul{i} = normalize(censor_noise_ul{i}, 'zscore');
			end
			test_sens_upper{i} = normalize(test_sens_upper{i}, 'zscore');
			test_sens_lower{i} = normalize(test_sens_lower{i}, 'zscore');
		end
		if others==1
			for i=1:size(censor_others, 2)
				censor_others(:,i) = normalize(censor_others(:,i), 'zscore');
			end
		end
	end
	selec_censor_main_upper = select_sensor(censor_main_upper, selected_sens_num);
	selec_censor_main_lower = select_sensor(censor_main_lower, selected_sens_num);
	if learn_ul == 1
		selec_censor_main_ul = select_sensor(censor_main_ul, selected_sens_num);
	end
	for i=1:length(censor_noise_upper)
		selec_censor_noise_upper{i} = select_sensor(censor_noise_upper{i}, selected_sens_num);
		selec_censor_noise_lower{i} = select_sensor(censor_noise_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_censor_noise_ul{i} = select_sensor(censor_noise_ul{i}, selected_sens_num);
		end
	end
	for i=1:num_test
		selec_test_sens_upper{i} = select_sensor(test_sens_upper{i}, selected_sens_num);
		selec_test_sens_lower{i} = select_sensor(test_sens_lower{i}, selected_sens_num);
		if learn_ul == 1
			selec_test_sens_ul{i} = select_sensor(test_sens_ul{i}, selected_sens_num);
		end
	end
	if others==1
		selec_censor_others = zeros(length(selected_sens_num), size(censor_others, 2));
		for i=1:size(censor_others, 2)
			selec_censor_others(:,i) = select_sensor(censor_others(:,i), selected_sens_num);
		end
	end

	X = [selec_censor_main_upper, selec_censor_main_lower];
	for i = 1:length(selec_censor_noise_lower)
		X = [X, selec_censor_noise_upper{i}];
		X = [X, selec_censor_noise_lower{i}];
	end
	Y = [];
	for i = 1:length(selec_censor_noise_lower)+1
		Y = [Y; 1; 0];
	end
	if learn_ul==1
		X = [X, selec_censor_main_ul];
		for i = 1:length(selec_censor_noise_ul)
			X = [X, selec_censor_noise_ul{i}];
		end
		Y = [Y; 2*ones(size(selec_censor_noise_ul,2)+1, 1)];
	end
	if others==1
		X = [X, selec_censor_others];
		Y = [Y; 3*ones(size(selec_censor_others,2), 1)];
	end

	X = X.';
	SVM = fitcecoc(X,Y,"Learners","svm");
	TREE = fitcecoc(X,Y,"Learners","tree");
	KER = fitcecoc(X,Y,'Learners','kernel');
	KNN = fitcecoc(X,Y,"Learners","knn");
	DIS = fitcecoc(X,Y,"Learners","discriminant");
	result_upper_svm = zeros(num_test, 1);
	result_lower_svm = zeros(num_test, 1);
	result_upper_tree = zeros(num_test, 1);
	result_lower_tree = zeros(num_test, 1);
	result_upper_ker = zeros(num_test, 1);
	result_lower_ker = zeros(num_test, 1);
	result_upper_knn = zeros(num_test, 1);
	result_lower_knn = zeros(num_test, 1);
	result_upper_dis = zeros(num_test, 1);
	result_lower_dis = zeros(num_test, 1);
	for i=1:num_test
		result_upper_svm(i) = predict(SVM, selec_test_sens_upper{i}.');
		result_lower_svm(i) = predict(SVM, selec_test_sens_lower{i}.');
		result_upper_tree(i) = predict(TREE, selec_test_sens_upper{i}.');
		result_lower_tree(i) = predict(TREE, selec_test_sens_lower{i}.');
		result_upper_ker(i) = predict(KER, selec_test_sens_upper{i}.');
		result_lower_ker(i) = predict(KER, selec_test_sens_lower{i}.');
		result_upper_knn(i) = predict(KNN, selec_test_sens_upper{i}.');
		result_lower_knn(i) = predict(KNN, selec_test_sens_lower{i}.');
		result_upper_dis(i) = predict(DIS, selec_test_sens_upper{i}.');
		result_lower_dis(i) = predict(DIS, selec_test_sens_lower{i}.');
	end
	counts = zeros(8,4);
	for i=1:num_test
		switch result_upper_svm(i)
			case 0
				counts(1,1) = counts(1,1) + 1;
			case 1
				counts(1,2) = counts(1,2) + 1;
			case 2
				counts(1,3) = counts(1,3) + 1;
			case 3
				counts(1,4) = counts(1,4) + 1;
		end
		switch result_lower_svm(i)
			case 0
				counts(2,1) = counts(2,1) + 1;
			case 1
				counts(2,2) = counts(2,2) + 1;
			case 2
				counts(2,3) = counts(2,3) + 1;
			case 3
				counts(2,4) = counts(2,4) + 1;
		end
		switch result_upper_tree(i)
			case 0
				counts(3,1) = counts(3,1) + 1;
			case 1
				counts(3,2) = counts(3,2) + 1;
			case 2
				counts(3,3) = counts(3,3) + 1;
			case 3
				counts(3,4) = counts(3,4) + 1;
		end
		switch result_lower_tree(i)
			case 0
				counts(4,1) = counts(4,1) + 1;
			case 1
				counts(4,2) = counts(4,2) + 1;
			case 2
				counts(4,3) = counts(4,3) + 1;
			case 3
				counts(4,4) = counts(4,4) + 1;
		end
		switch result_upper_knn(i)
			case 0
				counts(5,1) = counts(5,1) + 1;
			case 1
				counts(5,2) = counts(5,2) + 1;
			case 2
				counts(5,3) = counts(5,3) + 1;
			case 3
				counts(5,4) = counts(5,4) + 1;
		end
		switch result_lower_knn(i)
			case 0
				counts(6,1) = counts(6,1) + 1;
			case 1
				counts(6,2) = counts(6,2) + 1;
			case 2
				counts(6,3) = counts(6,3) + 1;
			case 3
				counts(6,4) = counts(6,4) + 1;
		end
		switch result_upper_dis(i)
			case 0
				counts(7,1) = counts(7,1) + 1;
			case 1
				counts(7,2) = counts(7,2) + 1;
			case 2
				counts(7,3) = counts(7,3) + 1;
			case 3
				counts(7,4) = counts(7,4) + 1;
		end
		switch result_lower_dis(i)
			case 0
				counts(8,1) = counts(8,1) + 1;
			case 1
				counts(8,2) = counts(8,2) + 1;
			case 2
				counts(8,3) = counts(8,3) + 1;
			case 3
				counts(8,4) = counts(8,4) + 1;
		end
	end
	output = {apart, 'lower', 'upper', 'upper&lower', 'others', 'accuracy'};
	output{2,1} = 'SVM_upper';
	output{3,1} = 'SVM_lower';
	output{4,1} = 'Tree_upper';
	output{5,1} = 'Tree_lower';
	output{6,1} = 'KNN_upper';
	output{7,1} = 'KNN_lower';
	output{8,1} = 'LDA_upper';
	output{9,1} = 'LDA_lower';
	for i=2:size(output,1)
		for j=2:size(output,2)
			if j<size(output,2)
				output{i,j} = counts(i-1, j-1);
			else
				if mod(i,2) == 0
					output{i,j} = counts(i-1, 2)/num_test;
				else
					output{i,j} = counts(i-1, 1)/num_test;
				end
			end
		end
	end
	output2 = zeros(4,1);
	output2(1) = (output{2,6}+output{3,6})/2;
	output2(2) = (output{4,6}+output{5,6})/2;
	output2(3) = (output{6,6}+output{7,6})/2;
	output2(4) = (output{8,6}+output{9,6})/2;
end

function out = select_sensor(c, s)
	tmp = [];
	for i=1:length(s)
		tmp = [tmp; c(s(i))];
	end
	out = tmp;
end