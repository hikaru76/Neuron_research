%% ���ڂ̎��s�̎������R�����g�A�E�g�O���Ď��s
addpath C:\Users\kotani\Documents\MATLAB\fieldtrip
ft_defaults
%% aparc+aseg��HCPMMP�̃}�X�N���g���ă\�[�X�O���b�h���쐬��Brainstorm�̍��W�ɕϊ�����
Subname = 'Sakamoto';
select=1;	%select 1:upper, 2:lower, 3:upper&lower
main = 1;	%main 1:main, 2:noise, 3:cortex_simulation�p
if strcmp(Subname, 'Sakamoto')
	subname='Sakamoto';
elseif strcmp(Subname, 'Sugino')
	subname='Sugino';
elseif strcmp(Subname, 'Mori')
	subname='Mori';
end
mri_bst = load(fullfile(subname,'subjectimage_MRI.mat')); % Brainstorm����B���W�ϊ��Ɏg�p?
mri_roi = ft_read_mri(fullfile(subname,'aparc+aseg.mgz')); % Recon-all����B����?�̈�̒��o�Ɏg�p?
mri_t1 = ft_read_mri(fullfile(subname, 'spmT_0001_FS.nii'));
mri_t2 = ft_read_mri(fullfile(subname, 'spmT_0002_FS.nii'));
mri_t3 = ft_read_mri(fullfile(subname, 'spmT_0003_FS.nii'));
grid_size = 5; % �O���b�h��(mm,���R��)

%% Making source grid
th = 5;
tmp = [];
bold = [];
roi_name = [];
for i = 1:grid_size:mri_roi.dim(1)
    for j = 1:grid_size:mri_roi.dim(2)
        for k = 1:grid_size:mri_roi.dim(3)
			if select==1
				if mri_t1.anatomy(i,j,k) >= th
                	tmp = [tmp; [i,j,k,1]];
					bold = [bold; mri_t1.anatomy(i,j,k)];
                	roi_name = [roi_name; 1];
				end
			elseif select==2
				if mri_t2.anatomy(i,j,k) >= th
                	tmp = [tmp; [i,j,k,1]];
					bold = [bold; mri_t2.anatomy(i,j,k)];
                	roi_name = [roi_name; 2];
				end
			elseif select==3
				if mri_t3.anatomy(i,j,k) >= th
                	tmp = [tmp; [i,j,k,1]];
					bold = [bold; mri_t3.anatomy(i,j,k)];
                	roi_name = [roi_name; 3];
				end
			end
        end
    end
end

%% Coordinate transformation
% pos = (mri_roi.transform*tmp')'; % �{�N�Z���̃C��??�N�X������W?�ւ̕ϊ�
pos_mm = (mri_roi.hdr.tkrvox2ras*tmp')'; % tkrvox -> ras(mm)
pos_m = pos_mm(:,1:3)*10^-3; % ras(mm) -> ras(m)
pos_origin = bst_bsxfun(@plus, pos_m, (size(mri_bst.Cube)/2 + [0 1 0]) .* mri_bst.Voxsize / 1000); % Origin adjustment
pos_bs = cs_convert(mri_bst, 'mri', 'scs', pos_origin); % ras(m) -> scs(m)
if strcmp(subname, 'Sakamoto')
	pos_bs(:,2) = -pos_bs(:,2);
end

%% Display
cortex = load(fullfile(subname, 'cortex_vertices_whole_brain_high.mat')).cortex;

%% bold�傫�����ɕ��ёւ��A�K�v�Ȍ����������o���i�Z���T�ʒu�œK���A���C�����Ε��ʑI��p�j
if main==1
	want = 100;
	tmp = [bold, pos_bs];
	[Y,I] = sort(tmp(:,1), 1, "descend");
	tmp1 = tmp(I,:);
	bold = tmp1(1:want, 1);
	pos_bs = tmp1(1:want, 2:4);

%% �Z���T�ʒu�œK���A���C���{�m�C�Y�I��p�j
elseif main==2
	want_main = 30;	%���C����bold��
	main_range = 100;
	want_random = 70;	%�m�C�Y��bold��
	tmp = [bold, pos_bs];
	[Y,I] = sort(tmp(:,1), 1, "descend");
	tmp1 = tmp(I,:);
	tmp2 = tmp1(1:main_range, :);
	rng(0, 'twister');
	b = randi([1,main_range], want_main,1);
	tmp_main = tmp1(b, :);
	tmp1 = tmp1(main_range+1:length(tmp1),:);
	num_sample = 1000;	%�m�C�Y��������Z�b�g��邩
	bold_noise = {};
	seed = 1:1:num_sample;
	for i = 1:num_sample
		if strcmp(test, 'test_')
			rng(seed(i), 'combRecursive'); %test�쐬�p�����V�[�h�ݒ�
		else
			rng(seed(i), 'twister');	%�����V�[�h�ݒ�
		end
		a = randi([1 length(tmp1)],want_random,1);
		bold_noise{i} = [tmp_main; read_bold(tmp1, a)];
	end
end

%%
% figure()
% scatter3(cortex.Vertices(1:10:length(cortex.Vertices),1),cortex.Vertices(1:10:length(cortex.Vertices),2),cortex.Vertices(1:10:length(cortex.Vertices),3),10,[0.5,0.5,0.5]);
% hold on
% scatter3(pos_bs(:,1),pos_bs(:,2),pos_bs(:,3),10,[1,0.4,0.4],'filled')
% hold off
% daspect([1 1 1])
% view(150,50)

function out = read_bold(b, a)
	t = [];
	for i = 1:length(a)
		t = [t; b(a(i),:)];
	end
	out = t;
end