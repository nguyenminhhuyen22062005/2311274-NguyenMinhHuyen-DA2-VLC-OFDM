%% QUICK_TEST - Kiem tra nhanh (~1 phut): dieu che/giai dieu che va chuan hoa SNR
cfg = init_sim();
fprintf('1) QAM Gray mod/demod khong nhieu:\n');
for M = [4 16 64 256]
    b = randi([0 1], log2(M), 1e4);
    s = qam_gray_mod(b, M);
    fprintf('   M=%3d  Es=%.3f  so bit sai=%d\n', M, mean(abs(s).^2), sum(sum(qam_gray_demod(s, M) ~= b)));
end
fprintf('2) Tin hieu DCO/ACO la so thuc va khong am sau bias/clip:\n');
o = default_opt();
for sch = {'dco', 'aco'}
    [~, Nd] = ofdm_subcarriers(sch{1}, o.N);
    X = reshape(qam_gray_mod(randi([0 1], 4, Nd*10), 16), Nd, 10);
    x = ofdm_ifft_hermitian(X, sch{1}, o.N);
    if strcmp(sch{1}, 'dco'), y = dco_bias_clip(x, 7, sqrt(2*Nd/o.N)); else, y = aco_clip(x); end
    fprintf('   %s: isreal=%d, min(y)=%.3f, E[x^2]=%.3f (ly thuyet %.3f)\n', upper(sch{1}), isreal(x), min(y(:)), mean(x(:).^2), 2*Nd/o.N);
end
fprintf('3) BER mo phong vs ly thuyet tai Eb(elec)/N0 = 14 dB (16-QAM):\n');
o.verbose = false;
r = sim_link('aco', 14, o); fprintf('   ACO      sim %.3e | ly thuyet %.3e\n', r.ber, ber_theory('aco', 14, o));
o.biasdB = 13;
r = sim_link('dco', 20, o); fprintf('   DCO 13dB sim %.3e | ly thuyet %.3e (tai 20 dB)\n', r.ber, ber_theory('dco', 20, o));
fprintf('4) Kiem tra chuan hoa: DCO bias 16 dB, che do ac (bo DC) phai trung OFDM luong cuc:\n');
o = default_opt(); o.verbose = false; o.biasdB = 16; o.snrMode = 'ac'; o.maxBits = 2e7; o.minErr = 500;
r = sim_link('dco', [10 14], o);
fprintf('   Eb/N0 = 10, 14 dB: sim %.3e, %.3e | ly thuyet %.3e, %.3e\n', r.ber, ber_qam_awgn(16, 4*10.^([10 14]/10)));
