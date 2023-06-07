% addpath C:\Users\kotani\Documents\MATLAB\fieldtrip
% ft_defaults
%% makesourcemodel, select_points, LeadfieldSimulationをまとめて実行。
%% 設定
% Subname = 'Mori';
% megeeg = 'EEG';
% save_ = 1;
% vert_num = '15002';
% num_noise = '1000';

%% いじらない
dir = append(Subname, '/', vert_num);

%% メイン
% main = 1;	%main 1:main, 2:noise
% main,train,upper
% select=1;	%select 1:upper, 2:lower, 3:upper&lower
% test = '';	%test test_:test, '':train
% makesourcemodel
% select_points
% main,train,lower
% select=2;
% makesourcemodel
% select_points
% main,train,ul
% select=3;
% makesourcemodel
% select_points

%% ノイズ入り
main = 2;	%main 1:main, 2:noise
% % noise,train,upper
% select=1;	%select 1:upper, 2:lower, 3:upper&lower
% test = '';	%test test_:test, '':train
% makesourcemodel
% select_points_noise
% % noise,train,lower
% select=2;
% makesourcemodel
% select_points_noise
% % noise,train,ul
% select=3;
% makesourcemodel
% select_points_noise

% noise,test,upper
select=1;
test = 'test_';
makesourcemodel
select_points_noise
% noise,test,lower
select=2;
makesourcemodel
select_points_noise
% noise,test,ul
select=3;
makesourcemodel
select_points_noise

%% センサ値算出
% % main,train,lower
% a = 1; %部位指定1:lower, 2:upper
% LeadfieldSimulation
% % main,train,upper
% a = 2;
% LeadfieldSimulation
% % main,train,ul
% a = 3;
% LeadfieldSimulation

% noise,train,lower
% a = 1;
% testornot = ''; %test:'test_', train:''
% LeadfieldSimulation_noise
% % noise,train,upper
% a = 2;
% LeadfieldSimulation_noise
% % noise,train,ul
% a = 3;
% LeadfieldSimulation_noise

% noise,test,lower
a = 1;
testornot = 'test_';
LeadfieldSimulation_noise
% noise,test,upper
a = 2;
LeadfieldSimulation_noise
% noise,test,ul
a = 3;
LeadfieldSimulation_noise