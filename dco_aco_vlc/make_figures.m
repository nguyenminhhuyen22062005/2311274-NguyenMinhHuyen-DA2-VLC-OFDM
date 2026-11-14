%% MAKE_FIGURES - Ve TOAN BO hinh cua bao cao bang MATLAB
% Chay sau run_all.m (can cac file CSV trong results/). Hinh duoc luu vao
% figures_matlab/ voi dung ten file ma bao cao dang dung:
%   Chuong 2: fig_subcarriers, fig_waveforms, fig_dco_bias_pdf,
%             fig_aco_spectrum, r4_led_response
%   Chuong 4: r1_ber_elec ... r13_snr_vs_se
% Nhan truc/chu thich trong hinh dung tieng Anh ky thuat de khong loi font
% tren moi phien ban MATLAB; chu thich tieng Viet nam trong bao cao.
cfg = init_sim();
% Octave tren Linux khong co man hinh (server) thi dung gnuplot de xuat anh;
% Octave tren Mac/Windows dung toolkit mac dinh (qt).
if cfg.isOctave && isunix && ~ismac && isempty(getenv('DISPLAY')) ...
        && any(strcmp(available_graphics_toolkits(), 'gnuplot'))
    graphics_toolkit('gnuplot');
end
R  = cfg.resDir;
OUT = fullfile(fileparts(mfilename('fullpath')), 'figures_matlab');
fprintf('\n===== MAKE_FIGURES -> %s =====\n', OUT);

% Bang mau (giong nhau tren moi hinh): ACO = xanh, DCO = cam
BLUE = [42 120 214]/255;  ORANGE = [235 104 52]/255;  GRAY = [0.45 0.45 0.45];
RED  = [0.80 0.20 0.17];
OR_R = [122 42 12; 168 64 15; 212 86 31; 235 104 52; 242 146 95; 247 184 147]/255;  % cam dam -> nhat
BL_R = [13 54 107; 24 79 149; 37 106 191; 57 135 229; 109 167 236; 158 197 244]/255; % xanh dam -> nhat
MS = 5;   % kich thuoc marker

%% ======================= CHUONG 2 =======================
% ---- Hinh 2.2: phan bo song mang (N = 32) ----
N = 32; k = 0:N-1;
f = fig_new(6.6, 4.6);
names = {'dco', 'aco'};
ttl = {'(a) DCO-OFDM: data on k = 1 ... N/2-1', '(b) ACO-OFDM: data on odd k only'};
for s = 1:2
    subplot(2, 1, s); hold on;
    idx = ofdm_subcarriers(names{s}, N);           % chi so MATLAB (1-based)
    kd = idx - 1;  km = N - kd;  kz = setdiff(k, [kd km]);
    h1 = stem(kd, ones(size(kd)), 'filled');  set(h1, 'Color', BLUE, 'MarkerFaceColor', BLUE, 'LineWidth', 1.4);
    h2 = stem(km, 0.75*ones(size(km)));       set(h2, 'Color', ORANGE, 'Marker', 's', 'MarkerFaceColor', ORANGE, 'LineWidth', 1.4);
    h3 = plot(kz, zeros(size(kz)), 'x');      set(h3, 'Color', GRAY, 'MarkerSize', 7, 'LineWidth', 1.4);
    plot([N/2 N/2], [-0.2 2.5], ':', 'Color', GRAY);
    axis([-1 N -0.2 2.5]); set(gca, 'YTick', []); fig_axes(); title(ttl{s});
    if s == 1, legend([h1 h2 h3], {'data X_k', 'Hermitian image X_{N-k} = X_k^*', 'X_k = 0'}, 'Location', 'north', 'Orientation', 'horizontal'); end
end
xlabel('Subcarrier index k (N = 32)');
fig_save(f, OUT, 'fig_subcarriers');

% ---- Hinh 2.3: dang song mot ky hieu (N = 64) ----
N = 64; M = 16; n = 0:N-1;
try, rng(7); catch, rand('state', 7); end %#ok<RAND>
[idx, Nd] = ofdm_subcarriers('dco', N);
xd = ofdm_ifft_hermitian(reshape(qam_gray_mod(randi([0 1], 4, Nd), M), Nd, 1), 'dco', N);
sd = sqrt(2*Nd/N);  mu = 2;  B = mu*sd;  yd = max(xd + B, 0);
[idx, Na] = ofdm_subcarriers('aco', N);
xa = ofdm_ifft_hermitian(reshape(qam_gray_mod(randi([0 1], 4, Na), M), Na, 1), 'aco', N);
ya = max(xa, 0);
f = fig_new(6.6, 7.2);
subplot(3, 1, 1); hold on;
plot(n, xd, '-o', 'Color', GRAY, 'MarkerSize', 3.5, 'MarkerFaceColor', GRAY);
neg = xd < 0; h = plot(n(neg), xd(neg), 'o', 'Color', RED, 'MarkerFaceColor', RED, 'MarkerSize', 4);
plot([0 N-1], [0 0], 'k-'); fig_axes(); xlim([0 N-1]); ylim([-4 5]); ylabel('Amplitude');
title('(a) Real bipolar OFDM signal after Hermitian IFFT'); legend(h, {'negative samples (cannot drive LED)'}, 'Location', 'north', 'Orientation', 'horizontal');
subplot(3, 1, 2); hold on;
h1 = plot(n, xd + B, '--', 'Color', GRAY);
h2 = plot(n, yd, '-o', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', 3.5, 'LineWidth', 1.3);
h3 = plot([0 N-1], [B B], ':', 'Color', 'k', 'LineWidth', 1);
plot([0 N-1], [0 0], 'k-'); fig_axes(); xlim([0 N-1]); ylim([-0.8 8.5]); ylabel('Amplitude');
title('(b) DCO-OFDM: add DC bias, clip what is still negative');
legend([h1 h2 h3], {'x[n] + B_{DC} before clipping', 'DCO signal to LED', 'bias B_{DC} = 2\sigma (7 dB)'}, 'Location', 'north', 'Orientation', 'horizontal');
subplot(3, 1, 3); hold on;
h1 = plot(n, xa, '--', 'Color', GRAY);
h2 = plot(n, ya, '-o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', 3.5, 'LineWidth', 1.3);
plot([N/2 N/2], [-2.2 3.6], ':', 'Color', GRAY); plot([0 N-1], [0 0], 'k-');
fig_axes(); xlim([0 N-1]); ylim([-2.2 3.6]); ylabel('Amplitude'); xlabel('Sample index n (one OFDM symbol, N = 64)');
title('(c) ACO-OFDM: odd subcarriers only, x[n+N/2] = -x[n], clip all negative samples');
legend([h1 h2], {'bipolar x[n]', 'ACO signal to LED'}, 'Location', 'north', 'Orientation', 'horizontal');
fig_save(f, OUT, 'fig_waveforms');

% ---- Hinh 2.4: phan bo bien do DCO va vung bi xen ----
z = -1:0.005:7;  pdfn = @(t, m) exp(-(t - m).^2/2)/sqrt(2*pi);
f = fig_new(6.6, 3.6); hold on;
bl = [4 7 10]; cols = OR_R([2 4 5], :); hh = zeros(1, 3); lab = cell(1, 3);
for i = 1:3
    m = sqrt(10^(bl(i)/10) - 1);
    zz = -1:0.005:0;  fill([zz fliplr(zz)], [pdfn(zz, m) zeros(size(zz))], 0.55*cols(i,:) + 0.45, 'EdgeColor', 'none');
end
for i = 1:3
    m = sqrt(10^(bl(i)/10) - 1);
    hh(i) = plot(z, pdfn(z, m), '-', 'Color', cols(i,:), 'LineWidth', 1.8);
    lab{i} = sprintf('bias %d dB (\\mu = %.2f): %.1f%% of samples clipped', bl(i), m, 100*qfun(m));
end
plot([0 0], [0 0.62], 'k-', 'LineWidth', 1.2); text(0.1, 0.47, 'LED turn-on threshold (clip at 0)', 'FontName', 'Times New Roman', 'FontSize', 9);
axis([-1 7 0 0.75]); fig_axes(); xlabel('Signal amplitude after biasing (in units of \sigma)'); ylabel('Probability density');
legend(hh, lab, 'Location', 'northeast');
fig_save(f, OUT, 'fig_dco_bias_pdf');

% ---- Hinh 2.5: pho ACO sau xen va chom sao song mang le ----
N = 64; S = 400; [idx, Na] = ofdm_subcarriers('aco', N);
X = reshape(qam_gray_mod(randi([0 1], 4, Na*S), 16), Na, S);
y = max(ofdm_ifft_hermitian(X, 'aco', N), 0);
Y = fft(y)/sqrt(N);
kk = 1:N/2-1; P = mean(abs(Y(kk+1, :)).^2, 2).';
f = fig_new(6.8, 3.9);
subplot(1, 2, 1); hold on;
o = mod(kk, 2) == 1;
b1 = bar(kk(o), P(o), 0.45);  set(b1, 'FaceColor', BLUE, 'EdgeColor', BLUE);
b2 = bar(kk(~o), P(~o), 0.45); set(b2, 'FaceColor', ORANGE, 'EdgeColor', ORANGE);
plot([0 N/2], [0.25 0.25], 'k--');
axis([0 N/2 0 0.42]); fig_axes(); xlabel('Subcarrier index k'); ylabel('Average power');
title('(a) ACO spectrum after clipping'); legend([b1 b2], {'odd: data, |X_k|^2/4', 'even: clipping noise'}, 'Location', 'northeast');
subplot(1, 2, 2); hold on;
Ys = 2*Y(idx(4), :);
h1 = plot(real(Ys), imag(Ys), 'o', 'Color', BLUE, 'MarkerSize', 8, 'LineWidth', 1.3);
lv = [-3 -1 1 3]/sqrt(10); [gx, gy] = meshgrid(lv, lv);
h2 = plot(gx(:), gy(:), 'k+', 'MarkerSize', 9, 'LineWidth', 1.3);
axis equal; axis([-1.4 1.4 -1.4 1.4]); fig_axes(); title('(b) Odd-subcarrier constellation (no noise)');
legend([h1 h2], {'2Y_k received', '16-QAM reference'}, 'Location', 'southoutside');
fig_save(f, OUT, 'fig_aco_spectrum');

% ---- Hinh 2.6: dap ung LED ----
N = 128; fn = (0:N/2)/(N/2); betas = [0.05 0.1 0.2 0.5 1];
f = fig_new(6.4, 3.4); hold on; hh = zeros(1, 5); lab = cell(1, 5);
for i = 1:5
    [~, ~, H] = led_lowpass(betas(i), N);
    hh(i) = plot(fn, 20*log10(abs(H(1:N/2+1))), '-', 'Color', BL_R(i, :), 'LineWidth', 1.6);
    lab{i} = sprintf('\\beta = %g', betas(i));
end
plot([0 1], [-3 -3], 'k:'); text(0.88, -2.2, '-3 dB', 'FontName', 'Times New Roman', 'FontSize', 9);
axis([0 1 -24 1]); fig_axes(); xlabel('Normalized frequency f/(f_s/2)  (subcarrier position k/(N/2))'); ylabel('|H(f)| (dB)');
legend(hh, lab, 'Location', 'southwest');
fig_save(f, OUT, 'r4_led_response');

%% ======================= CHUONG 4 =======================
% helper: dummy entries cho chu giai "duong = giai tich, diem = mo phong"
% ---- Hinh 4.1 / 4.2: BER theo Eb(elec)/N0 va Eb(opt)/N0 ----
files = {'exp1_ber_elec.csv', 'exp1_ber_opt.csv'}; xl = {'E_{b(elec)}/N_0 (dB)', 'E_{b(opt)}/N_0 (dB)'};
outn = {'r1_ber_elec', 'r2_ber_opt'};
for q = 1:2
    T = csv_named(fullfile(R, files{q})); fnm = fieldnames(T); x = T.(fnm{1});
    f = fig_new(6.6, 5.4); hold on; set(gca, 'YScale', 'log');
    h = [];
    h(end+1) = semilogy(x, nanpos(T.ACO_sim), 'o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', MS);
    semilogy(x, nanpos(T.ACO_th), '-', 'Color', BLUE, 'LineWidth', 1.2);
    mk = {'s', '^', 'v'}; bb = [7 10 13]; cc = OR_R([2 4 5], :);
    for i = 1:3
        h(end+1) = semilogy(x, nanpos(T.(sprintf('DCO%d_sim', bb(i)))), mk{i}, 'Color', cc(i,:), 'MarkerFaceColor', cc(i,:), 'MarkerSize', MS);
        semilogy(x, nanpos(T.(sprintf('DCO%d_th', bb(i)))), '-', 'Color', cc(i,:), 'LineWidth', 1.2);
    end
    lab = {'ACO-OFDM', 'DCO-OFDM, bias 7 dB', 'DCO-OFDM, bias 10 dB', 'DCO-OFDM, bias 13 dB'};
    if isfield(T, 'bipolar_ideal')
        h(end+1) = semilogy(x, nanpos(T.bipolar_ideal), 'k--', 'LineWidth', 1.1); lab{end+1} = 'ideal bipolar OFDM (16-QAM)';
    end
    h(end+1) = plot(NaN, NaN, '-', 'Color', GRAY);  lab{end+1} = 'lines: analysis';
    h(end+1) = plot(NaN, NaN, 'o', 'Color', GRAY);  lab{end+1} = 'markers: simulation';
    plot([0 34], [1e-3 1e-3], ':', 'Color', GRAY);
    axis([0 34 1e-6 0.5]); fig_axes(); xlabel(xl{q}); ylabel('BER');
    fig_legend(h, lab, 2);
    fig_save(f, OUT, outn{q});
end

% ---- Hinh 4.3: cung hieu suat pho ----
T = csv_named(fullfile(R, 'exp1_ber_eqse.csv')); x = T.EbN0dB;
f = fig_new(6.6, 5.2); hold on; set(gca, 'YScale', 'log'); h = zeros(1, 5);
h(1) = semilogy(x, nanpos(T.ACO16_sim), 'o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', MS);   semilogy(x, nanpos(T.ACO16_th), '-', 'Color', BLUE);
h(2) = semilogy(x, nanpos(T.DCO4_sim), 's', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', MS); semilogy(x, nanpos(T.DCO4_th), '-', 'Color', ORANGE);
h(3) = semilogy(x, nanpos(T.ACO256_sim), '^', 'Color', BLUE, 'MarkerSize', MS);   semilogy(x, nanpos(T.ACO256_th), '--', 'Color', BLUE);
h(4) = semilogy(x, nanpos(T.DCO16_sim), 'v', 'Color', ORANGE, 'MarkerSize', MS);  semilogy(x, nanpos(T.DCO16_th), '--', 'Color', ORANGE);
h(5) = plot(NaN, NaN, '-', 'Color', GRAY);
plot([0 34], [1e-3 1e-3], ':', 'Color', GRAY);
axis([0 34 1e-6 0.5]); fig_axes(); xlabel('E_{b(elec)}/N_0 (dB)'); ylabel('BER');
fig_legend(h, {'ACO 16-QAM (0.89 bit/s/Hz)', 'DCO 4-QAM (0.88 bit/s/Hz)', 'ACO 256-QAM (1.78 bit/s/Hz)', 'DCO 16-QAM (1.75 bit/s/Hz)', 'lines: analysis, markers: simulation'}, 2);
fig_save(f, OUT, 'r3_ber_eqse');

% ---- Hinh 4.8: BER theo beta ----
T = csv_named(fullfile(R, 'exp2_ber_vs_beta.csv')); b = T.beta; b(b == 99) = 5;
f = fig_new(6.6, 5.0); hold on; set(gca, 'XScale', 'log', 'YScale', 'log'); h = zeros(1, 5);
h(1) = loglog(b, nanpos(T.ACO_20dB_sim), 'o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', MS);   loglog(b, nanpos(T.ACO_20dB_th), '-', 'Color', BLUE);
h(2) = loglog(b, nanpos(T.DCO_20dB_sim), 's', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', MS); loglog(b, nanpos(T.DCO_20dB_th), '-', 'Color', ORANGE);
h(3) = loglog(b, nanpos(T.ACO_26dB_sim), 'o', 'Color', BLUE, 'MarkerSize', MS);   loglog(b, nanpos(T.ACO_26dB_th), '--', 'Color', BLUE);
h(4) = loglog(b, nanpos(T.DCO_26dB_sim), 's', 'Color', ORANGE, 'MarkerSize', MS); loglog(b, nanpos(T.DCO_26dB_th), '--', 'Color', ORANGE);
h(5) = plot(NaN, NaN, '-', 'Color', GRAY);
axis([0.045 5.5 1e-7 0.5]); fig_axes();
set(gca, 'XTick', [0.05 0.1 0.2 0.5 1 2 5], 'XTickLabel', {'0.05', '0.1', '0.2', '0.5', '1', '2', 'Inf'});
xlabel('Normalized LED bandwidth \beta = f_c/(f_s/2)'); ylabel('BER');
fig_legend(h, {'ACO, E_b/N_0 = 20 dB', 'DCO 7 dB bias, 20 dB', 'ACO, 26 dB', 'DCO 7 dB bias, 26 dB', 'lines: analysis'}, 2);
fig_save(f, OUT, 'r5_ber_vs_beta');

% ---- Hinh 4.9: BER theo SNR voi nhieu beta ----
T = csv_named(fullfile(R, 'exp2_ber_curves.csv')); x = T.EbN0dB;
f = fig_new(7.0, 3.8);
sch = {'ACO', 'DCO'}; RR = {BL_R, OR_R}; ttl = {'ACO-OFDM', 'DCO-OFDM (7 dB bias)'};
bk = {'01', '02', '05', 'Inf'}; bl = {'\beta = 0.1', '\beta = 0.2', '\beta = 0.5', '\beta = Inf'}; mk = {'o', 's', '^', 'v'}; ci = [1 2 4 5];
for s = 1:2
    subplot(1, 2, s); hold on; set(gca, 'YScale', 'log'); h = zeros(1, 4);
    for i = 1:4
        c = RR{s}(ci(i), :);
        h(i) = semilogy(x, nanpos(T.([sch{s} '_b' bk{i} '_sim'])), mk{i}, 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 4);
        semilogy(x, nanpos(T.([sch{s} '_b' bk{i} '_th'])), '-', 'Color', c);
    end
    axis([0 40 1e-6 0.5]); fig_axes(); xlabel('E_{b(elec)}/N_0 (dB)'); if s == 1, ylabel('BER'); end
    title(ttl{s}); legend(h, bl, 'Location', 'southwest');
end
fig_save(f, OUT, 'r6_ber_curves_led');

% ---- Hinh 4.10: penalty theo beta ----
T = csv_named(fullfile(R, 'exp2_penalty.csv')); b = T.beta; b(b == 99) = 5;
f = fig_new(6.4, 3.8); hold on; set(gca, 'XScale', 'log');
h1 = semilogx(b, T.ACO_pen_sim, 'o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', 6); semilogx(b, T.ACO_pen_th, '-', 'Color', BLUE);
h2 = semilogx(b, T.DCO_pen_sim, 's', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', 6); semilogx(b, T.DCO_pen_th, '-', 'Color', ORANGE);
axis([0.045 5.5 -1 22]); fig_axes();
set(gca, 'XTick', [0.05 0.1 0.2 0.5 1 2 5], 'XTickLabel', {'0.05', '0.1', '0.2', '0.5', '1', '2', 'Inf'});
xlabel('Normalized LED bandwidth \beta'); ylabel('SNR penalty at BER = 10^{-3} (dB)');
legend([h1 h2], {'ACO-OFDM', 'DCO-OFDM (7 dB bias)'}, 'Location', 'northeast');
fig_save(f, OUT, 'r7_led_penalty');

% ---- Hinh 4.4: BER theo SNR voi nhieu muc bias ----
T = csv_named(fullfile(R, 'exp3_ber_curves.csv')); x = T.EbN0dB; E = csv_named(fullfile(R, 'exp1_ber_elec.csv'));
f = fig_new(6.6, 5.2); hold on; set(gca, 'YScale', 'log');
bb = [5 7 9 11 13]; mk = {'o', 's', '^', 'v', 'd'}; cc = OR_R([1 2 3 5 6], :); h = zeros(1, 6); lab = cell(1, 6);
for i = 1:5
    h(i) = semilogy(x, nanpos(T.(sprintf('DCO%d_sim', bb(i)))), mk{i}, 'Color', cc(i,:), 'MarkerFaceColor', cc(i,:), 'MarkerSize', MS);
    semilogy(x, nanpos(T.(sprintf('DCO%d_th', bb(i)))), '-', 'Color', cc(i,:));
    lab{i} = sprintf('DCO, bias %d dB', bb(i));
end
h(6) = semilogy(E.EbN0dB, nanpos(E.ACO_sim), 'o--', 'Color', BLUE, 'MarkerSize', 4); lab{6} = 'ACO-OFDM (reference)';
plot([0 34], [1e-3 1e-3], ':', 'Color', GRAY);
axis([0 34 1e-6 0.5]); fig_axes(); xlabel('E_{b(elec)}/N_0 (dB)'); ylabel('BER'); fig_legend(h, lab, 3);
fig_save(f, OUT, 'r8_ber_bias_curves');

% ---- Hinh 4.5: BER theo bias tai SNR co dinh ----
T = csv_named(fullfile(R, 'exp3_ber_vs_bias.csv')); bb = T.biasdB;
f = fig_new(6.6, 5.0); hold on; set(gca, 'YScale', 'log');
ss = [18 22 26]; mk = {'o', 's', '^'}; cc = OR_R([2 4 5], :); h = zeros(1, 4); lab = cell(1, 4);
for i = 1:3
    h(i) = semilogy(bb, nanpos(T.(sprintf('DCO_%ddB_sim', ss(i)))), mk{i}, 'Color', cc(i,:), 'MarkerFaceColor', cc(i,:), 'MarkerSize', MS);
    semilogy(bb, nanpos(T.(sprintf('DCO_%ddB_th', ss(i)))), '-', 'Color', cc(i,:));
    lab{i} = sprintf('DCO, E_b/N_0 = %d dB', ss(i));
end
h(4) = semilogy(bb, nanpos(T.ACO_18dB_sim), ':', 'Color', BLUE, 'LineWidth', 1.6); lab{4} = 'ACO, 18 dB (no errors at 22, 26 dB)';
axis([3 16 1e-8 0.5]); fig_axes(); xlabel('DC bias (dB) = 10log_{10}(1+\mu^2)'); ylabel('BER'); fig_legend(h, lab, 2);
fig_save(f, OUT, 'r9_ber_vs_bias');

% ---- Hinh 4.6: SNR yeu cau theo bias ----
T = csv_named(fullfile(R, 'exp3_penalty.csv'));
f = fig_new(6.4, 4.0); hold on;
h1 = plot(T.biasdB, T.req_th, '-', 'Color', ORANGE, 'LineWidth', 1.6);
ok = ~isnan(T.req_sim); h2 = plot(T.biasdB(ok), T.req_sim(ok), 's', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', 6);
h3 = plot([4 16], T.ACO_req(1)*[1 1], '--', 'Color', BLUE, 'LineWidth', 1.4);
h4 = plot([4 16], T.ideal_req(1)*[1 1], 'k:', 'LineWidth', 1.4);
[mn, im] = min(T.req_th); text(T.biasdB(im) + 0.3, mn - 2.2, sprintf('optimum at about %.1f dB', T.biasdB(im)), 'FontName', 'Times New Roman', 'FontSize', 9);
axis([4 16 8 32]); fig_axes(); xlabel('DC bias (dB)'); ylabel('Required E_{b(elec)}/N_0 at BER = 10^{-3} (dB)');
legend([h1 h2 h3 h4], {'DCO-OFDM (analysis)', 'DCO-OFDM (simulation)', sprintf('ACO-OFDM (%.1f dB)', T.ACO_req(1)), sprintf('ideal bipolar OFDM (%.1f dB)', T.ideal_req(1))}, 'Location', 'northeast');
fig_save(f, OUT, 'r10_bias_penalty');

% ---- Hinh 4.7: xen hai phia ----
T = csv_named(fullfile(R, 'exp3_clip_top.csv')); cr = T.CRdB;
f = fig_new(6.6, 4.9); hold on; set(gca, 'YScale', 'log'); h = zeros(1, 5);
h(1) = semilogy(cr, nanpos(T.ACO_28dB_sim), 'o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', MS);   semilogy(cr, nanpos(T.ACO_28dB_th), '-', 'Color', BLUE);
h(2) = semilogy(cr, nanpos(T.DCO_28dB_sim), 's', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'MarkerSize', MS); semilogy(cr, nanpos(T.DCO_28dB_th), '-', 'Color', ORANGE);
h(3) = semilogy(cr, nanpos(T.ACO_32dB_sim), 'o', 'Color', BLUE, 'MarkerSize', MS);   semilogy(cr, nanpos(T.ACO_32dB_th), '--', 'Color', BLUE);
h(4) = semilogy(cr, nanpos(T.DCO_32dB_sim), 's', 'Color', ORANGE, 'MarkerSize', MS); semilogy(cr, nanpos(T.DCO_32dB_th), '--', 'Color', ORANGE);
h(5) = plot(NaN, NaN, '-', 'Color', GRAY);
axis([0 20 1e-7 0.5]); fig_axes(); xlabel('Clipping ratio 20log_{10}(I_{max}/\sigma) (dB)'); ylabel('BER');
fig_legend(h, {'ACO, E_{b(peak)}/N_0 = 28 dB', 'DCO, 28 dB', 'ACO, 32 dB', 'DCO, 32 dB', 'lines: analysis'}, 2);
fig_save(f, OUT, 'r11_clip_top');

% ---- Hinh 4.11: PAPR ----
T = csv_named(fullfile(R, 'exp4_papr_ccdf.csv')); g = T.gamma_dB;
f = fig_new(7.2, 4.6);
subplot(1, 2, 1); hold on; set(gca, 'YScale', 'log'); h = zeros(1, 5);
h(1) = semilogy(g, nanpos(T.DCO_bipolar_L4), '-', 'Color', OR_R(2,:), 'LineWidth', 1.5);
h(2) = semilogy(g, nanpos(T.DCO_biased_L4), '-', 'Color', OR_R(5,:), 'LineWidth', 1.5);
h(3) = semilogy(g, nanpos(T.ACO_L4), '-', 'Color', BLUE, 'LineWidth', 1.5);
semilogy(g, nanpos(T.DCO_bipolar_L1), '--', 'Color', OR_R(2,:)); semilogy(g, nanpos(T.ACO_L1), '--', 'Color', BLUE);
h(4) = semilogy(g, nanpos(T.bipolar_th), 'k:', 'LineWidth', 1.2); semilogy(g, nanpos(T.ACO_th), 'k:', 'LineWidth', 1.2);
h(5) = plot(NaN, NaN, '--', 'Color', GRAY);
axis([4 18 1e-4 1.2]); fig_axes(); xlabel('\gamma (dB)'); ylabel('CCDF = Pr(PAPR > \gamma)'); title('(a) Electrical PAPR');
legend(h, {'DCO bipolar (L = 4)', 'DCO after 7 dB bias (L = 4)', 'ACO (L = 4)', 'theory (L = 1)', 'simulation L = 1'}, 'Location', 'southoutside');
subplot(1, 2, 2); hold on; set(gca, 'YScale', 'log');
h1 = semilogy(g, nanpos(T.DCO_biased_opt), '-', 'Color', OR_R(5,:), 'LineWidth', 1.5);
h2 = semilogy(g, nanpos(T.ACO_opt), '-', 'Color', BLUE, 'LineWidth', 1.5);
axis([2 12 1e-4 1.2]); fig_axes(); xlabel('\gamma (dB)'); title('(b) Optical PAPR  max y / E[y]');
legend([h1 h2], {'DCO, 7 dB bias', 'ACO'}, 'Location', 'southoutside');
fig_save(f, OUT, 'r12_papr');

% ---- Hinh 4.12: SNR yeu cau theo hieu suat pho ----
T = csv_named(fullfile(R, 'exp5_summary.csv'));
f = fig_new(7.0, 3.9); key = {'req_elec_sim', 'req_opt_sim'}; ttl = {'(a) electrical power', '(b) optical power'};
yl = {'Required E_{b(elec)}/N_0 (dB)', 'Required E_{b(opt)}/N_0 (dB)'};
for s = 1:2
    subplot(1, 2, s); hold on;
    a = T.isDCO == 0; d = T.isDCO == 1;
    h1 = plot(T.SE(a), T.(key{s})(a), '-o', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'LineWidth', 1.5);
    h2 = plot(T.SE(d), T.(key{s})(d), '-s', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'LineWidth', 1.5);
    % nhan M: duong nam tren thi ghi phia tren-trai, duong nam duoi ghi phia duoi-phai
    up = {-0.05, 0.9, 'right'}; dn = {0.05, -0.9, 'left'};
    if s == 1, la = up; ld = dn; else, la = dn; ld = up; end
    for i = find(a).', text(T.SE(i) + la{1}, T.(key{s})(i) + la{2}, sprintf('M=%d', T.M(i)), 'FontName', 'Times New Roman', 'FontSize', 8, 'HorizontalAlignment', la{3}); end
    for i = find(d).', text(T.SE(i) + ld{1}, T.(key{s})(i) + ld{2}, sprintf('M=%d', T.M(i)), 'FontName', 'Times New Roman', 'FontSize', 8, 'HorizontalAlignment', ld{3}); end
    v = T.(key{s});
    xlim([0.2 2.9]); ylim([2*floor(min(v)/2) - 2, 2*ceil(max(v)/2) + 4]);
    fig_axes(); xlabel('Spectral efficiency (bit/s/Hz)'); ylabel(yl{s}); title(ttl{s});
    legend([h1 h2], {'ACO-OFDM', 'DCO-OFDM (model-opt. bias)'}, 'Location', 'northwest');
end
fig_save(f, OUT, 'r13_snr_vs_se');

% ---- Thi nghiem 6: quet bias bang mo phong quanh muc toi uu giai tich ----
f6 = fullfile(R, 'exp6_bias_sweep.csv');
if exist(f6, 'file')
    T = csv_named(f6); Ms = unique(T.M).';
    f = fig_new(7.0, 3.6);
    for s = 1:numel(Ms)
        subplot(1, numel(Ms), s); hold on;
        k = T.M == Ms(s);
        h1 = plot(T.biasdB(k), T.req_elec_th(k), '-', 'Color', GRAY, 'LineWidth', 1.4);
        h2 = plot(T.biasdB(k), T.req_elec_sim(k), '-o', 'Color', ORANGE, 'MarkerFaceColor', ORANGE, 'LineWidth', 1.5);
        b0 = T.biasdB(k & T.offset_from_analytic == 0);
        [~, j] = min(T.req_elec_sim(k)); bb = T.biasdB(k); ss = T.req_elec_sim(k);
        h3 = plot(bb(j), ss(j), 'p', 'Color', BLUE, 'MarkerFaceColor', BLUE, 'MarkerSize', 10);
        yl = ylim; plot([b0 b0], yl, ':', 'Color', GRAY); ylim(yl);
        fig_axes(); xlabel('DC bias (dB)'); title(sprintf('DCO %d-QAM', Ms(s)));
        if s == 1, ylabel('Required E_{b(elec)}/N_0 (dB)'); end
    end
    fig_legend([h1 h2 h3], {'analytical', 'simulation', 'best (sim.)'}, 3);
    fig_save(f, OUT, 'r14_bias_sweep');
end
fprintf('Xong. Hinh nam trong %s\n', OUT);
