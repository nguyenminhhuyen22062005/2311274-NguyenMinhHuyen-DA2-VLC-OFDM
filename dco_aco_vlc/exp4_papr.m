%% EXP4 - So sanh PAPR (CCDF) cua DCO-OFDM va ACO-OFDM
%   PAPR = max y^2 / E[y^2] tren moi ky hieu OFDM (khong tinh CP)
%   L = 1: lay mau Nyquist; L = 4: lay mau tang 4 lan (gan voi tin hieu tuong tu)
% Ket qua:
%   results/exp4_papr_ccdf.csv   CCDF Pr(PAPR > gamma)
%   results/exp4_papr_stats.csv  PAPR tai CCDF = 1e-3, ti so dinh/trung binh quang
cfg = init_sim();
fprintf('\n===== EXP4: PAPR =====\n');
N = 128; M = 16; Nsym = 50000; biasdB = 7;
g = (0:0.05:20).';                         % nguong gamma (dB)
data = g; hdr = {'gamma_dB'};
stats = [];
for L = [1 4]
    % --- DCO ---
    [idx, Nd] = ofdm_subcarriers('dco', N);
    X = reshape(qam_gray_mod(randi([0 1], log2(M), Nd*Nsym), M), Nd, Nsym);
    xd = ofdm_ifft_hermitian(X, 'dco', N, L);         % luong cuc
    sig = sqrt(2*Nd/N);
    yd = dco_bias_clip(xd, biasdB, sig);              % sau bias 7 dB + clip
    % --- ACO ---
    [idx, Na] = ofdm_subcarriers('aco', N);
    Xa = reshape(qam_gray_mod(randi([0 1], log2(M), Na*Nsym), M), Na, Nsym);
    xa = ofdm_ifft_hermitian(Xa, 'aco', N, L);
    ya = aco_clip(xa);
    P = {papr_db(xd), papr_db(yd), papr_db(xa), papr_db(ya)};
    names = {'DCO_bipolar', 'DCO_biased', 'ACO_bipolar', 'ACO'};
    for i = 1:4
        c = zeros(size(g));
        for j = 1:numel(g), c(j) = mean(P{i} > g(j)); end
        data = [data, c];
        hdr = [hdr, {sprintf('%s_L%d', names{i}, L)}];
        ps = sort(P{i});
        p3 = ps(round((1 - 1e-3)*numel(ps)));           % PAPR tai CCDF = 1e-3
        stats = [stats; L, i, mean(P{i}), p3];
        fprintf('  L=%d %-12s PAPR trung binh = %5.2f dB, PAPR@1e-3 = %5.2f dB\n', L, names{i}, mean(P{i}), p3);
    end
    % PAPR QUANG: cuong do quang ti le voi y (khong phai y^2) =>
    %   PAPR_opt = 10log10( max y / E[y] ) tren moi ky hieu
    %   (lien quan truc tiep den dai dong LED va do sang trung binh)
    if L == 4
        Q = {10*log10(max(yd, [], 1) ./ mean(yd, 1)), 10*log10(max(ya, [], 1) ./ mean(ya, 1))};
        qn = {'DCO_biased_opt', 'ACO_opt'};
        for i = 1:2
            c = zeros(size(g));
            for j = 1:numel(g), c(j) = mean(Q{i} > g(j)); end
            data = [data, c]; hdr = [hdr, {qn{i}}];
            ps = sort(Q{i}); p3 = ps(round((1 - 1e-3)*numel(ps)));
            stats = [stats; 4, 4 + i, mean(Q{i}), p3];
            fprintf('  L=4 %-14s PAPR quang trung binh = %5.2f dB, @1e-3 = %5.2f dB\n', qn{i}, mean(Q{i}), p3);
        end
    end
end
% CCDF ly thuyet (L = 1, mau doc lap): luong cuc 1-(1-2Q(sqrt(g)))^N ; ACO 1-(1-Q(sqrt(g/2)))^N
gl = 10.^(g/10);
data = [data, 1 - (1 - 2*qfun(sqrt(gl))).^N, 1 - (1 - qfun(sqrt(gl/2))).^N];
hdr = [hdr, {'bipolar_th', 'ACO_th'}];
write_csv(fullfile(cfg.resDir, 'exp4_papr_ccdf.csv'), hdr, data);
write_csv(fullfile(cfg.resDir, 'exp4_papr_stats.csv'), {'L', 'case', 'mean_dB', 'papr_at_1e-3_dB'}, stats);
% case: 1 DCO luong cuc, 2 DCO sau bias, 3 ACO truoc clip, 4 ACO, 5/6 PAPR quang DCO/ACO

if cfg.plot
    figure; hold on; grid on; box on;
    c = data(:, 2:end);
    semilogy(g, c(:, 5), 'r-', g, c(:, 6), 'm-', g, c(:, 8), 'b-', g, c(:, 9), 'k:', g, c(:, 10), 'k--');
    set(gca, 'YScale', 'log'); ylim([1e-4 1]); xlim([4 18]);
    xlabel('\gamma (dB)'); ylabel('Pr(PAPR > \gamma)');
    legend('DCO luong cuc (L=4)', 'DCO bias 7dB (L=4)', 'ACO (L=4)', 'Ly thuyet luong cuc (L=1)', 'Ly thuyet ACO (L=1)');
    save_fig(cfg, 'exp4_papr');
end
