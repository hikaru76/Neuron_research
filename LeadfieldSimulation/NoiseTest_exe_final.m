%% kmean, SVM, SimNoiseTest, exeの最初のブロックがコメントアウトされているか確認。
num_test = 1000; %テストケースを何個入れるか：100 or 1000

%% 定数
sn = 20;
num_noise = '100';
solver='L1QP'; % ISDA, L1QP, SMO kmeansセンサ最適化でどのSVMsolverを用いるか
select_noise = 3; % 0:ノイズなし 1:ホワイトガウスノイズ, 2:上下反対の値, 3:両方
ratio = 0.2; % 上下反対の値の割合。0-1
ratio_ul = 0.1; % テストケースにupper&lowerを入れる割合。0-1
learn_ul = 1; % upper&lowerを学習させるか。0or1
others = 1; % 完全なるランダム値（他の領野が働いていると仮定）を学習させるか 0or1

Subname = 'Sugino';
% megeeg='EEG';
% want=8;
% NoiseTest_exe;
megeeg='MEG';
% want=20;
NoiseTest_exe;
Subname = 'Mori';
% megeeg='EEG';
% want=8;
% NoiseTest_exe;
% megeeg='MEG';
% want=20;
NoiseTest_exe;
Subname = 'Sakamoto';
% megeeg='EEG';
% want=8;
% NoiseTest_exe;
% megeeg='MEG';
% want=20;
NoiseTest_exe;