%% EXP2 - Anh huong cua bang thong LED (bo loc thong thap bac 1)
% beta = fc/(fs/2): bang thong LED chuan hoa theo bang thong tin hieu.
% May thu biet kenh (CSI ly tuong) va can bang ZF 1-tap tren tung song mang.
% Ket qua:
%   results/exp2_led_response.csv   |H(f)| (dB) theo tan so chuan hoa
%   results/exp2_ber_vs_beta.csv    BER theo beta tai Eb(elec)/N0 co dinh
%   results/exp2_ber_curves.csv     BER theo Eb(elec)/N0 voi mot so beta
%   results/exp2_penalty.csv        SNR yeu cau @BER 1e-3 va penalty theo beta
cfg = init_sim();
fprintf('\n===== EXP2: LED bandwidth =====\n');
base = default_opt(); base.maxBits = 1e7;
base.biasdB = 7;                      % DCO dung bias 7 dB (co the doi)
N = base.N;

%% Dap ung tan so LED
betas_plot = [0.05 0.1 0.2 0.5 1];
f = (0:N/2).'/(N/2);                  % tan so chuan hoa f/(fs/2)
Hdb = f;
for i = 1:numel(betas_plot)
    [~, ~, H] = led_lowpass(betas_plot(i), N);
    Hdb = [Hdb, 20*log10(abs(H(1:N/2+1)))];
end
write_csv(fullfile(cfg.resDir, 'exp2_led_response.csv'), ...
    {'f_norm', 'b005', 'b01', 'b02', 'b05', 'b1'}, Hdb);
fprintf('  beta  | f3dB thuc te (chuan hoa) | |H| tai song mang cao nhat\n');
for b = [0.05 0.1 0.2 0.3 0.5 1]
    [~, ~, H, fe] = led_lowpass(b, N);
    fprintf('  %.2f  |  %.3f  |  %.2f dB\n', b, fe, 20*log10(abs(H(N/2))));
end

%% BER theo beta tai Eb/N0 co dinh
betas = [0.05 0.075 0.1 0.15 0.2 0.3 0.5 0.7 1 2 Inf];
snrFix = [20 26];
data = betas(:); hdr = {'beta'};
for s = snrFix
    for sch = {'aco', 'dco'}
        bs = zeros(numel(betas), 1); bt = bs;
        for i = 1:numel(betas)
            o = base; o.beta = betas(i); o.verbose = false;
            r = sim_link(sch{1}, s, o);
            bs(i) = r.ber; bt(i) = ber_theory(sch{1}, s, o);
            fprintf('  %s beta=%5.3f Eb/N0=%d dB  BER sim=%.3e  th=%.3e\n', ...
                upper(sch{1}), betas(i), s, bs(i), bt(i));
        end
        data = [data, bs, bt];
        hdr = [hdr, {sprintf('%s_%ddB_sim', upper(sch{1}), s), ...
                     sprintf('%s_%ddB_th', upper(sch{1}), s)}];
    end
end
data(isinf(data)) = 99;               % beta = Inf ghi la 99 trong CSV
write_csv(fullfile(cfg.resDir, 'exp2_ber_vs_beta.csv'), hdr, data);

%% Duong BER theo SNR voi mot so beta
EbN0 = 0:1:40;
betas_c = [0.1 0.2 0.5 Inf];
data2 = EbN0(:); hdr2 = {'EbN0dB'};
pen = [];
for sch = {'aco', 'dco'}
    for b = betas_c
        o = base; o.beta = b;
        r = sim_link(sch{1}, EbN0, o);
        th = ber_theory(sch{1}, EbN0, o);
        data2 = [data2, r.ber(:), th(:)];
        tag = sprintf('%s_b%s', upper(sch{1}), strrep(num2str(b), '.', ''));
        hdr2 = [hdr2, {[tag '_sim'], [tag '_th']}];
    end
end
write_csv(fullfile(cfg.resDir, 'exp2_ber_curves.csv'), hdr2, data2);

%% SNR yeu cau (BER = 1e-3) va penalty so voi LED ly tuong
betas_p = [0.05 0.075 0.1 0.15 0.2 0.3 0.5 0.7 1 2 Inf];
pen = betas_p(:);
for sch = {'aco', 'dco'}
    o = base; o.beta = Inf;
    s0 = required_snr_theory(sch{1}, cfg.target, o);
    st = zeros(numel(betas_p), 1); ss = st;
    for i = 1:numel(betas_p)
        o.beta = betas_p(i);
        st(i) = required_snr_theory(sch{1}, cfg.target, o);
        % kiem chung bang mo phong quanh diem giai tich
        sgrid = floor(st(i)) - 3 : 0.5 : ceil(st(i)) + 4;
        oo = o; oo.verbose = false; oo.minBER = 1e-4;
        r = sim_link(sch{1}, sgrid, oo);
        ss(i) = required_snr(sgrid, r.ber, cfg.target);
        fprintf('  %s beta=%5.3f  SNR yeu cau: th=%.2f dB, sim=%.2f dB\n', ...
            upper(sch{1}), betas_p(i), st(i), ss(i));
    end
    % penalty: giai tich so voi giai tich LED ly tuong; mo phong so voi mo phong
    % LED ly tuong (beta = Inf la phan tu cuoi cua betas_p)
    pen = [pen, st, ss, st - s0, ss - ss(end)];
end
pen(isinf(pen)) = 99;
write_csv(fullfile(cfg.resDir, 'exp2_penalty.csv'), ...
    {'beta', 'ACO_req_th', 'ACO_req_sim', 'ACO_pen_th', 'ACO_pen_sim', ...
             'DCO_req_th', 'DCO_req_sim', 'DCO_pen_th', 'DCO_pen_sim'}, pen);

if cfg.plot
    figure; grid on; box on; hold on;
    b = data(:, 1); b(b == 99) = 4;
    semilogx(b, data(:, 2), 'bo', b, data(:, 3), 'b-', b, data(:, 4), 'rs', b, data(:, 5), 'r-');
    semilogx(b, data(:, 6), 'bo--', b, data(:, 8), 'rs--');
    set(gca, 'XScale', 'log', 'YScale', 'log');
    xlabel('\beta = f_c / (f_s/2)'); ylabel('BER');
    legend('ACO sim 20dB', 'ACO ly thuyet 20dB', 'DCO sim 20dB', 'DCO ly thuyet 20dB', ...
           'ACO sim 26dB', 'DCO sim 26dB');
    title('BER theo bang thong LED chuan hoa');
    save_fig(cfg, 'exp2_ber_vs_beta');
end
