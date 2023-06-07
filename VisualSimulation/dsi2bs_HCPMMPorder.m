% scoutsとneuron_verticesは自分で保存(data/visual_scouts, visual_verticesに対応)
% dsiのconnectivityなどをbsi用に順番を変える(HCPMMP)
subname = 'Sakamoto';
Numbers = [144,145,149]; %欲しい領野の変数scoutの行番号
dsi_order = [51 72 90 65 88 91 92 52 38 32 40 41 164 162 161 35 58 53 9 8 99 74 75 84 76 66 94 103 12 39 36 37 96 54 44 55 78 56 42 45 30 47 46 29 68 67 70 63 73 86 87 69 71 24 89 61 59 179 175 77 125 85 112 117 111 34 62 142 118 10 18 113 115 114 108 169 157 120 97 79 80 82 81 168 146 145 144 17 174 95 48 20 21 159 173 109 50 2 23 93 101 102 100 170 180 57 64 60 171 83 124 27 122 11 148 105 149 147 116 150 143 151 138 126 155 127 137 178 110 22 166 167 106 31 15 119 121 25 104 14 165 98 43 26 123 128 129 176 130 28 107 132 177 133 134 136 135 131 172 139 140 141 1 4 33 5 13 19 158 6 156 3 152 16 7 49 153 160 154 163 231 252 270 245 268 271 272 232 218 212 220 221 344 342 341 215 238 233 189 188 279 254 255 264 256 246 274 283 192 219 216 217 276 234 224 235 258 236 222 225 210 227 226 209 248 247 250 243 253 266 267 249 251 204 269 241 239 359 355 257 305 265 292 297 291 214 242 322 298 190 198 293 295 294 288 349 337 300 277 259 260 262 261 348 326 325 324 197 354 275 228 200 201 339 353 289 230 182 203 273 281 282 280 350 360 237 244 240 351 263 304 207 302 191 328 285 329 327 296 330 323 331 318 306 335 307 317 358 290 202 346 347 286 211 195 299 301 205 284 194 345 278 223 206 303 308 309 356 310 208 287 312 357 313 314 316 315 311 352 319 320 321 181 184 213 185 193 199 338 186 336 183 332 196 187 229 333 340 334 343];
bs_order = [7 1 2 3 4 5 6 13 8 9 10 11 12 14 15 16 17 18 19 27 20 21 22 23 24 25 26 28 29 30 31 32 33 34 35 36 37 38 39 40 44 41 42 43 45 46 47 48 49 50 51 52 53 54 161 162 163 164 55 165 56 166 57 58 59 167 168 60 61 62 63 64 65 66 67 68 69 70 169 71 72 73 74 79 75 76 77 78 80 81 82 83 84 85 86 88 87 89 90 91 92 93 94 170 171 172 173 174 175 176 95 96 116 97 98 99 100 101 102 103 104 105 110 106 107 108 109 112 117 111 177 118 119 113 114 120 121 115 122 123 178 179 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 180 149 146 147 148 150 151 153 152 154 155 156 157 158 159 160 187 181 182 183 184 185 186 193 188 189 190 191 192 194 195 196 197 198 199 207 200 201 202 203 204 205 206 208 209 210 211 212 213 214 215 216 217 218 219 220 224 221 222 223 225 226 227 228 229 230 231 232 233 234 341 342 343 344 235 345 236 346 237 238 239 347 348 240 241 242 243 244 245 246 247 248 249 250 349 251 252 253 254 259 255 256 257 258 260 261 262 263 264 265 266 268 267 269 270 271 272 273 274 350 351 352 353 354 355 356 275 276 296 277 278 279 280 281 282 283 284 285 290 286 287 288 289 292 297 291 357 298 299 293 294 300 301 295 302 303 358 359 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 360 329 326 327 328 330 331 333 332 334 335 336 337 338 339 340];
dsi_connectivity = load(fullfile(subname, 'whole_brain_HCP-MMP_connectivity.mat')).connectivity;
dsi_synapse_len = load(fullfile(subname, 'whole_brain_HCP-MMP_synapse.mat')).connectivity;
tmp1 = zeros(360, 360);
tmp2 = zeros(360, 360);
bs_connectivity = zeros(360, 360);
bs_synapse_len = zeros(360, 360);
for i=1:360
	tmp1(:,bs_order(i)) = dsi_connectivity(:,dsi_order(i));
	tmp2(:,bs_order(i)) = dsi_synapse_len(:,dsi_order(i));
end
for i=1:360
	bs_connectivity(bs_order(i),:) = tmp1(dsi_order(i),:);
	bs_synapse_len(bs_order(i),:) = tmp2(dsi_order(i),:);
end

%% 領野ごとに挿入(HCPMMPには全verticeが含まれているわけではないのでHHCPMMPにあるverticesをまず選択してやる。vertices:cell配列)
pial = load(fullfile(subname, "cortex_vertices_whole_brain_high.mat")).cortex;
scout = load(fullfile(subname, 'scout_whole_brain_high.mat')).Scouts;
ver_len = zeros(length(Numbers),1);
total_num = 0;
for i=1:length(Numbers)
	ver_len(i) = length(scout(Numbers(i)).Vertices);
	total_num = total_num + ver_len(i);
end
vertices = {};
scouts = [];
neuron_vertices = [];
for i=1:length(Numbers)
	vertices{i} = read_vertices(scout(Numbers(i)).Vertices, pial.Vertices);
	scouts = [scouts, scout(Numbers(i)).Vertices];
	neuron_vertices = [neuron_vertices; vertices{i}];
end
selec_bs_connectivity = zeros(length(Numbers));
selec_bs_synapse_len = zeros(length(Numbers));
for i=1:length(Numbers)
	for j=1:length(Numbers)
		selec_bs_connectivity(i,j) = bs_connectivity(Numbers(i),Numbers(j));
		selec_bs_synapse_len(i,j) = bs_synapse_len(Numbers(i),Numbers(j));
	end
end
bs_connectivity = selec_bs_connectivity;
bs_synapse_len = selec_bs_synapse_len;

%% CPの最大値調べる用
% M=0;
% for k=1:1
% 	for l=k:k
% 		ConnectionLength = zeros(length(vertices{k}), length(vertices{l}));
% 		for i = 1:length(vertices{k})
% 			ConnectionLength(i,:) = vecnorm(vertices{k}(i,:)-vertices{l},2,2);
% 		end
% 		CP = (ones(length(vertices{k}), length(vertices{l}))./ConnectionLength);
% 		CP(~isfinite(CP)) = 0;
% 		M = max(max(max(CP)),M);
% 	end
% end

%% 異なる領野間結合確率生成
bs = bs_connectivity;
cn = bs/max(max(bs_connectivity));
cn = cn/100; %100個の頂点に乗せる。
connect12 = randi([1,ver_len(1)],100,1)*2-1; %v1v2の結合のv1の番号
connect21 = randi([ver_len(1)+1, ver_len(1)+ver_len(2)],100,1)*2-1;%v1v2の結合のv2の番号
connect23 = randi([ver_len(1)+1, ver_len(1)+ver_len(2)],100,1)*2-1;%v2v3の結合のv2の番号
connect32 = randi([ver_len(1)+ver_len(2)+1, ver_len(1)+ver_len(2)+ver_len(3)],100,1)*2-1;%v2v3の結合のv3の番号
connect13 = randi([1,ver_len(1)],100,1)*2-1; %v1v3の結合のv1の番号
connect31 = randi([ver_len(1)+ver_len(2)+1, ver_len(1)+ver_len(2)+ver_len(3)],100,1)*2-1;%v1v3の結合のv3の番号
%%
p2 = zeros(total_num*2,total_num*2);
p2(connect12, connect21) = cn(1,2);
p2(connect12+1, connect21+1) = cn(1,2);
p2(connect21, connect12) = cn(1,2);
p2(connect21+1, connect12+1) = cn(1,2);
p2(connect13, connect31) = cn(1,3);
p2(connect13+1, connect31+1) = cn(1,3);
p2(connect31, connect13) = cn(1,3);
p2(connect31+1, connect13+1) = cn(1,3);
p2(connect32, connect23) = cn(3,2);
p2(connect32+1, connect23+1) = cn(3,2);
p2(connect23, connect32) = cn(3,2);
p2(connect23+1, connect32+1) = cn(3,2);
g_bar = repmat([4.069*10^-3, 2.672*10^-2; 3.276*10^-3, 2.138*10^-2], [total_num, total_num]);
Neuron_num = repmat([42000 10500], [1, total_num]);
p2 = g_bar.*Neuron_num.*p2;

%% 異なる領野間伝達遅延作成
tau_n = round(bs_synapse_len/100*100*100);
tau2 = zeros(total_num*2, total_num*2);
tau2 = {};
tau2{1,1} = ones(ver_len(1)*2,ver_len(1)*2)*tau_n(1,1);
tau2{1,2} = ones(ver_len(1)*2,ver_len(2)*2)*tau_n(1,2);
tau2{1,3} = ones(ver_len(1)*2,ver_len(3)*2)*tau_n(1,3);
tau2{2,1} = ones(ver_len(2)*2,ver_len(1)*2)*tau_n(2,1);
tau2{2,2} = ones(ver_len(2)*2,ver_len(2)*2)*tau_n(2,2);
tau2{2,3} = ones(ver_len(2)*2,ver_len(3)*2)*tau_n(2,3);
tau2{3,1} = ones(ver_len(3)*2,ver_len(1)*2)*tau_n(3,1);
tau2{3,2} = ones(ver_len(3)*2,ver_len(2)*2)*tau_n(3,2);
tau2{3,3} = ones(ver_len(3)*2,ver_len(3)*2)*tau_n(3,3);
tau2 = [tau2{1,1}, tau2{1,2}, tau2{1,3};tau2{2,1}, tau2{2,2}, tau2{2,3};tau2{3,1}, tau2{3,2}, tau2{3,3}];

%% 領野間結合の結合確率保存
p3574 = sparse(p2.*logical(tau2==3574));
p4052 = sparse(p2.*logical(tau2==4052));
p3257 = sparse(p2.*logical(tau2==3257));
save('Sakamoto/parameter/p3574.mat', 'p3574')
save('Sakamoto/parameter/p4052.mat', 'p4052')
save("Sakamoto/parameter/p3257.mat", 'p3257')

%% 距離に基づく結合確率,伝達遅延作成
P = [];
tau = [];
for k=1:3
	tmp_p = [];
	tmp_tau = [];
	for l=1:3
		ConnectionLength = zeros(length(vertices{k}), length(vertices{l}));
		for i = 1:length(vertices{k})
			ConnectionLength(i,:) = vecnorm(vertices{k}(i,:)-vertices{l},2,2);
        end
		CP = exp(-ConnectionLength*2000);
		tmp = zeros(length(vertices{k})*2, length(vertices{l})*2);
		for i=1:length(vertices{k})
			for j=1:length(vertices{l})
				tmp(2*i-1:2*i,2*j-1:2*j) = round(ConnectionLength(i,j)*100000);
			end
		end
		tmp_tau = [tmp_tau,tmp]; %100000: m→mm, 0.01ms/step
		p = zeros(length(vertices{k})*2, length(vertices{l})*2);
		for i=1:length(vertices{k})
			for j=1:length(vertices{l})
				if k==l && i==j
% 					p(2*i-1, 2*j-1:2*j) = CP(i,j);
% 					p(2*i, 2*j-1) = CP(i,j);
					p(2*i-1:2*i, 2*j-1:2*j) = CP(i,j);
				else
					p(2*i-1:2*i, 2*j-1) = CP(i,j);
				end
			end
		end
 		g_bar = repmat([4.069*10^-3, 2.672*10^-2; 3.276*10^-3, 2.138*10^-2], [length(vertices{k}), length(vertices{l})]);
 		Neuron_num = repmat([42000 10500], [1, length(vertices{l})]);
 		p = g_bar.*Neuron_num.*p;
		tmp_p = [tmp_p,p];
	end
	P = [P;tmp_p];
	tau = [tau;tmp_tau];
end
P=P*0.2;

%%
tmp_tau = tau.*logical(P>0);
a = logical(tau==0);
tmp = tmp_tau;
tmp(tmp>=1 & tmp<=75) = 50;
tmp(tmp>=76 & tmp<=125) = 100;
tmp(tmp>=126 & tmp<=175) = 150;
tmp(tmp>=176 & tmp<=225) = 200;
tmp(tmp>=226 & tmp<=275) = 250;
tmp(tmp>=276 & tmp<=325) = 300;
tmp(tmp>=326 & tmp<=375) = 350;
tmp(tmp>=376 & tmp<=425) = 400;
tmp(tmp>=426 & tmp<=475) = 450;
tmp(tmp>=476 & tmp<=1500) = 1000;
tmp(tmp>=1501 & tmp<=2500) = 2000;
tmp(tmp>=2501 & tmp<=3500) = 3000;
tmp(tmp>=3501 & tmp<=4500) = 4000;
tmp(tmp>=4501) = 5000;
tmp_tau = tmp;
p0 = sparse(P.*logical(a==1));
p50 = sparse(P.*logical(tmp_tau==50));
p100 = sparse(P.*logical(tmp_tau==100));
p150 = sparse(P.*logical(tmp_tau==150));
p200 = sparse(P.*logical(tmp_tau==200));
p250 = sparse(P.*logical(tmp_tau==250));
p300 = sparse(P.*logical(tmp_tau==300));
p350 = sparse(P.*logical(tmp_tau==350));
p400 = sparse(P.*logical(tmp_tau==400));
p450 = sparse(P.*logical(tmp_tau==450));
p1000 = sparse(P.*logical(tmp_tau==1000));
p2000 = sparse(P.*logical(tmp_tau==2000));
p3000 = sparse(P.*logical(tmp_tau==3000));
p4000 = sparse(P.*logical(tmp_tau==4000));
p5000 = sparse(P.*logical(tmp_tau==5000));
%%
% save('Sakamoto/parameter/p0.mat', 'p0');
% save('Sakamoto/parameter/p50.mat', 'p50');
% save('Sakamoto/parameter/p100.mat', 'p100');
% save('Sakamoto/parameter/p150.mat', 'p150');
% save('Sakamoto/parameter/p200.mat', 'p200');
% save('Sakamoto/parameter/p250.mat', 'p250');
% save('Sakamoto/parameter/p300.mat', 'p300');
% save('Sakamoto/parameter/p350.mat', 'p350');
% save('Sakamoto/parameter/p400.mat', 'p400');
% save('Sakamoto/parameter/p450.mat', 'p450');
% save('Sakamoto/parameter/p1000.mat', 'p1000');
% save('Sakamoto/parameter/p2000.mat', 'p2000');
% save('Sakamoto/parameter/p3000.mat', 'p3000');
% save('Sakamoto/parameter/p4000.mat', 'p4000');
% save('Sakamoto/parameter/p5000.mat', 'p5000');

%% Iの作成 
% Subname = 'Sakamoto';
% dir = append(Subname, '/parameter');
% I = load(fullfile(dir,'I.mat')).I;
% tmp = [];
% for i=1:total_num
% 	tmp = [tmp; I(i); 0];
% end
% I=tmp;

function ver = read_vertices(x, v)    %x:Scouts.Vertices, v:pial.Vertices
    tmp = [];
    for i = 1:length(x)
        tmp = cat(1, tmp, v(x(i),:));
    end
    ver = tmp;
end