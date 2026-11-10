%% EXP3 - Anh huong cua DC bias (DCO-OFDM) va clipping
% Ket qua:
%   results/exp3_ber_vs_bias.csv     BER theo bias tai Eb(elec)/N0 co dinh
%   results/exp3_ber_curves.csv      BER theo Eb(elec)/N0 voi nhieu muc bias
%   results/exp3_penalty.csv         Eb/N0 yeu cau @1e-3 va power penalty theo bias
%   results/exp3_clip_top.csv        Clipping 2 phia khi LED gioi han dai dong
cfg = init_sim();
fprintf('\n===== EXP3: DC bias & clipping =====\n');
base = default_opt(); base.maxBits = 1e7;

%% (a) BER theo bias tai Eb/N0 co dinh
bias = 3:1:16;
snrFix = [18 22 26];
data = bias(:); hdr = {'biasdB'};
for s = snrFix
    bs = zeros(numel(bias), 1); bt = bs;
    for i = 1:numel(bias)
        o = base; o.biasdB = bias(i); o.verbose = false;
        r = sim_link('dco', s, o);
        bs(i) = r.ber; bt(i) = ber_theory('dco', s, o);
        fprintf('  bias=%2d dB Eb/N0=%d dB  BER sim=%.3e th=%.3e\n', bias(i), s, bs(i), bt(i));
    end
    data = [data, bs, bt];
    hdr = [hdr, {sprintf('DCO_%ddB_sim', s), sprintf('DCO_%ddB_th', s)}];
end
% ACO tai cung Eb/N0 (tham chieu)
for s = snrFix
    o = base; o.verbose = false;
    r = sim_link('aco', s, o);
    data = [data, r.ber*ones(numel(bias), 1)];
    hdr = [hdr, {sprintf('ACO_%ddB_sim', s)}];
end
write_csv(fullfile(cfg.resDir, 'exp3_ber_vs_bias.csv'), hdr, data);

%% (b) Duong BER theo Eb/N0 voi nhieu muc bias
EbN0 = 0:1:34;
biasC = [5 7 9 11 13];
data2 = EbN0(:); hdr2 = {'EbN0dB'};
for b = biasC
    o = base; o.biasdB = b;
    r = sim_link('dco', EbN0, o);
    th = ber_theory('dco', EbN0, o);
    data2 = [data2, r.ber(:), th(:)];
    hdr2 = [hdr2, {sprintf('DCO%d_sim', b), sprintf('DCO%d_th', b)}];
end
write_csv(fullfile(cfg.resDir, 'exp3_ber_curves.csv'), hdr2, data2);

%% (c) Eb/N0 yeu cau va power penalty theo bias
s_ideal = req_snr_bipolar(16, cfg.target);     % OFDM luong cuc ly tuong (dB)
o = base; s_aco = required_snr_theory('aco', cfg.target, o);
biasP = 4:0.5:16;
st = nan(numel(biasP), 1); ss = st;
for i = 1:numel(biasP)
    o = base; o.biasdB = biasP(i);
    st(i) = required_snr_theory('dco', cfg.target, o);
    if mod(biasP(i), 1) == 0
        g0 = st(i); if isnan(g0), g0 = 30; end
        sgrid = floor(g0) - 3 : 0.5 : ceil(g0) + 5;
        oo = o; oo.verbose = false; oo.minBER = 1e-4;
        r = sim_link('dco', sgrid, oo);
        ss(i) = required_snr(sgrid, r.ber, cfg.target);
    end
    fprintf('  bias=%4.1f dB  Eb/N0 yeu cau: th=%.2f sim=%.2f dB\n', biasP(i), st(i), ss(i));
end
write_csv(fullfile(cfg.resDir, 'exp3_penalty.csv'), ...
    {'biasdB', 'req_th', 'req_sim', 'pen_vs_ideal_th', 'pen_vs_ideal_sim', 'ACO_req', 'ideal_req'}, ...
    [biasP(:), st, ss, st - s_ideal, ss - s_ideal, s_aco*ones(size(st)), s_ideal*ones(size(st))]);
fprintf('  Tham chieu: OFDM luong cuc ly tuong = %.2f dB, ACO = %.2f dB\n', s_ideal, s_aco);

%% (d) LED gioi han dai dong [0, Imax]: clipping ca 2 phia
% Nhieu tham chieu theo cong suat dinh (snrMode = 'peak'), thay doi ti so
% xen CR = Imax/sigma. DCO dat bias o giua dai dong (B = Imax/2), ACO bias = 0.
CRdB = 0:1:20;                        % 20log10(Imax/sigma)
peakSNR = [28 32];                    % Eb(peak)/N0 (dB)
data4 = CRdB(:); hdr4 = {'CRdB'};
for ps = peakSNR
    for sch = {'aco', 'dco'}
        [~, Nd] = ofdm_subcarriers(sch{1}, base.N);
        sig = sqrt(2*Nd/base.N);
        bs = zeros(numel(CRdB), 1); bt = bs;
        for i = 1:numel(CRdB)
            CR = 10^(CRdB(i)/20);
            o = base; o.snrMode = 'peak'; o.clipTop = CR*sig; o.verbose = false;
            o.biasdB = 10*log10(1 + (CR/2)^2);  % B = Imax/2
            r = sim_link(sch{1}, ps, o);
            bs(i) = r.ber; bt(i) = ber_theory(sch{1}, ps, o);
        end
        data4 = [data4, bs, bt];
        hdr4 = [hdr4, {sprintf('%s_%ddB_sim', upper(sch{1}), ps), sprintf('%s_%ddB_th', upper(sch{1}), ps)}];
        fprintf('  %s Eb(peak)/N0=%d dB: BER min = %.2e tai CR = %d dB\n', upper(sch{1}), ps, min(bs), CRdB(find(bs == min(bs), 1)));
    end
end
write_csv(fullfile(cfg.resDir, 'exp3_clip_top.csv'), hdr4, data4);

if cfg.plot
    figure; grid on; box on; hold on;
    plot(biasP, st, 'r-', biasP, ss, 'rs');
    plot(biasP, s_aco*ones(size(biasP)), 'b--', biasP, s_ideal*ones(size(biasP)), 'k:');
    xlabel('DC bias (dB)'); ylabel('E_{b(elec)}/N_0 yeu cau @ BER = 10^{-3} (dB)');
    legend('DCO ly thuyet', 'DCO mo phong', 'ACO', 'OFDM luong cuc ly tuong');
    save_fig(cfg, 'exp3_penalty');
end

