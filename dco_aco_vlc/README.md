# Đồ án 2: So sánh DCO-OFDM và ACO-OFDM cho hệ thống VLC giới hạn băng thông

Sinh viên: Nguyễn Minh Huyền, Khoa Điện, Điện tử, Trường Đại học Bách Khoa, ĐHQG TP.HCM.

Chương trình mô phỏng MATLAB so sánh hai kỹ thuật OFDM quang cho truyền thông bằng ánh sáng nhìn thấy dùng điều chế cường độ và tách sóng trực tiếp: DCO-OFDM, cộng DC bias rồi xén phần âm, và ACO-OFDM, chỉ dùng sóng mang lẻ rồi xén toàn bộ phần âm. Hai hệ thống dùng chung kích thước FFT, bậc điều chế, kênh LED và cách chuẩn hóa công suất để so sánh công bằng về BER, hiệu suất phổ, PAPR, ảnh hưởng của DC bias và của băng thông LED.

## 1. Code tham khảo ban đầu

Repo này được fork từ [SamuelDSR/VLC](https://github.com/SamuelDSR/VLC). Các file gốc của tác giả vẫn giữ nguyên ở thư mục gốc của repo để đối chiếu. Toàn bộ code của đồ án nằm trong thư mục `dco_aco_vlc/`.

Code gốc không chạy được trên MATLAB hiện tại và có nhiều lỗi làm sai kết quả, nên phần mô phỏng được viết lại, giữ cách chia khối của repo gốc. Chi tiết ở mục 5.

## 2. Cài đặt

- MATLAB R2016b trở lên, không cần Communications Toolbox. Đã chạy thử trên MATLAB Online R2026b.
- Hoặc GNU Octave 7 trở lên. Đã chạy toàn bộ trên GNU Octave 8.4.
- Không cần cài thêm gói nào.

```bash
git clone https://github.com/<tai-khoan>/<ten-repo>.git
cd <ten-repo>/dco_aco_vlc
```

Nếu không có MATLAB trên máy: nén thư mục `dco_aco_vlc`, tải lên MATLAB Drive của MATLAB Online, giải nén bằng `unzip` rồi chạy như dưới. Bản MATLAB Online basic giới hạn 15 phút tính toán liên tục mỗi lần, đủ cho chế độ `quick` và `figures`.

## 3. Cách chạy

Trong MATLAB, chọn `dco_aco_vlc` làm Current Folder:

| Lệnh | Việc làm | Thời gian |
|---|---|---|
| `run_all_experiments('quick')` | Chạy `quick_test.m`: kiểm tra QAM, tín hiệu thực và không âm, BER mô phỏng khớp giải tích, chuẩn hóa SNR | khoảng 1 phút |
| `run_all_experiments('figures')` | Từ `results/*.csv` có sẵn: xuất MAT và JSON, vẽ lại toàn bộ 17 hình của báo cáo | khoảng 1 phút |
| `run_all_experiments('full')` hoặc `run_all_experiments` | Chạy kiểm tra, 5 thí nghiệm, xuất MAT và JSON, vẽ hình | 40 đến 60 phút |

Chạy riêng từng thí nghiệm: `exp1_ber_vs_snr`, `exp2_led_bandwidth`, `exp3_dc_bias`, `exp4_papr`, `exp5_summary`.

Thử một cấu hình tùy ý:

```matlab
addpath('lib');
o = default_opt(); o.M = 64; o.biasdB = 9; o.beta = 0.3;
r  = sim_link('dco', 10:2:36, o);   % mô phỏng Monte Carlo
bt = ber_theory('dco', 10:2:36, o); % mô hình giải tích Bussgang và ZF
semilogy(r.EbN0dB, r.ber, 'o', r.EbN0dB, bt, '-'); grid on
```

## 4. Tham số chính

Mặc định trong `lib/default_opt.m`:

| Tham số | Giá trị | Ý nghĩa |
|---|---|---|
| `N` | 128 | Kích thước FFT, giống nhau cho hai hệ thống |
| `Ncp` | 16 | Độ dài tiền tố tuần hoàn, bằng N/8 |
| `M` | 16 | Bậc QAM, thí nghiệm 1b và 5 dùng thêm 4, 64, 256 |
| `biasdB` | 7 | DC bias của DCO, bias dB = 10·log10(1 + μ²), B_DC = μσ; 7 dB ứng với μ = 2 |
| `clipTop` | Inf | Ngưỡng xén trên, Inf là không xén trên |
| `beta` | Inf | Băng thông LED chuẩn hóa β = fc/(fs/2), Inf là LED lý tưởng |
| `snrMode` | `'elec'` | Cách chuẩn hóa SNR: `elec` P = E[y²] có DC, `opt` P = (E[y])², `ac` P = var(y), `peak` P = Imax² |
| `minErr`, `maxBits` | 200, 4·10⁶ | Mỗi điểm SNR dừng khi đủ 200 lỗi hoặc đủ số bit; thí nghiệm 1, 3, 5 dùng 10⁷ bit |
| seed | 2026 | `rng(2026)` trong `init_sim.m`, chạy lại ra cùng kết quả |

Định nghĩa SNR: Eb/N0 = N·P / (2·nb·σn²), P đo trên tín hiệu phát sau bias và xén, không tính CP. Hiệu suất phổ = log2(M)·Nd / (N + Ncp) theo quy ước B = fs; nếu dùng băng thông vật lý một phía fs/2 thì nhân 2. BER mục tiêu để tính SNR yêu cầu là 10⁻³.

## 5. Các phần đã sửa và thêm so với code gốc

Lỗi của code gốc đã sửa:

| Vấn đề trong code gốc | Cách xử lý |
|---|---|
| `qam_modulator.m` dùng `modem.qammod`, API đã bị loại khỏi MATLAB | Viết `lib/qam_gray_mod.m`, `lib/qam_gray_demod.m`, mã Gray, Es = 1 |
| `aco_ofdm_main.m` lỗi `cell2mat` do truyền sai kiểu vào hàm QAM | Viết lại khối ACO trong `lib/aco_clip.m` và `lib/sim_link.m` |
| `dco_ofdm_main.m` tắt kênh, nhiễu và scaling bằng comment nên không có BER thật | Viết lại toàn bộ liên kết trong `lib/sim_link.m` |
| `qam_demodulator.m` nhân `sqrt(nf)/P` thay vì `sqrt(nf/P)` | Sửa thang biên độ |
| DC bias theo giá trị tuyệt đối 1 A, không gắn với σ | Bias theo μσ, tính bằng dB trong `lib/dco_bias_clip.m` |
| Hai script DCO và ACO dùng tham số khác nhau | Dùng chung `lib/default_opt.m` |
| Cân bằng ZF bị comment | Cân bằng ZF một tap trong `lib/sim_link.m` |
| `dco_clipping_noise.m` trả NaN khi không xén trên | `lib/clipping_noise_var.m`, `lib/clipped_moments.m` |
| `led_lp_channel.m` dùng FIR cắt cụt | `lib/led_lowpass.m`, IIR bậc một theo β |

Phần thêm mới:

- Chuẩn hóa công suất thống nhất cho hai hệ thống theo bốn chế độ `elec`, `opt`, `ac`, `peak`.
- Mô hình giải tích dựa trên định lý Bussgang và cân bằng ZF: `lib/ber_theory.m`, `lib/ber_qam_awgn.m`, `lib/optimum_bias.m`, `lib/required_snr_theory.m`.
- Mô hình LED thông thấp bậc một với tham số β.
- Thống kê PAPR với lấy mẫu tăng L = 4: `lib/papr_db.m`, `exp4_papr.m`.
- Năm thí nghiệm `exp1` đến `exp5`, bộ kiểm tra `quick_test.m`.
- Xuất kết quả ra CSV, MAT, JSON: `lib/write_csv.m`, `lib/export_results.m`.
- Vẽ toàn bộ hình của báo cáo bằng MATLAB: `make_figures.m`.
- Script chạy một lệnh: `run_all_experiments.m`.

## 6. Tái tạo kết quả trong báo cáo

| Hình hoặc bảng trong báo cáo | Script sinh dữ liệu | File kết quả | File hình |
|---|---|---|---|
| Hình 2.2 đến 2.5 | `make_figures.m` tự tính | | `fig_subcarriers`, `fig_waveforms`, `fig_dco_bias_pdf`, `fig_aco_spectrum` |
| Hình 2.6 | `exp2_led_bandwidth.m` | `exp2_led_response` | `r4_led_response` |
| Hình 4.1, Bảng 4.1 | `exp1_ber_vs_snr.m` | `exp1_ber_elec` | `r1_ber_elec` |
| Hình 4.2 | `exp1_ber_vs_snr.m` | `exp1_ber_opt` | `r2_ber_opt` |
| Hình 4.3 | `exp1_ber_vs_snr.m` | `exp1_ber_eqse` | `r3_ber_eqse` |
| Hình 4.4 | `exp3_dc_bias.m` | `exp3_ber_curves` | `r8_ber_bias_curves` |
| Hình 4.5 | `exp3_dc_bias.m` | `exp3_ber_vs_bias` | `r9_ber_vs_bias` |
| Hình 4.6, Bảng 4.2 | `exp3_dc_bias.m` | `exp3_penalty` | `r10_bias_penalty` |
| Hình 4.7 | `exp3_dc_bias.m` | `exp3_clip_top` | `r11_clip_top` |
| Hình 4.8 | `exp2_led_bandwidth.m` | `exp2_ber_vs_beta` | `r5_ber_vs_beta` |
| Hình 4.9 | `exp2_led_bandwidth.m` | `exp2_ber_curves` | `r6_ber_curves_led` |
| Hình 4.10, Bảng 4.3 | `exp2_led_bandwidth.m` | `exp2_penalty` | `r7_led_penalty` |
| Hình 4.11, Bảng 4.4 | `exp4_papr.m` | `exp4_papr_ccdf`, `exp4_papr_stats` | `r12_papr` |
| Hình 4.12, Bảng 4.5 | `exp5_summary.m` | `exp5_summary` | `r13_snr_vs_se` |
| Bảng 3.6, Phụ lục B | `quick_test.m` | in ra Command Window | |

Hình 2.1 và 3.1 là sơ đồ khối, được vẽ trực tiếp trong file Word của báo cáo.

## 7. Định dạng kết quả

- `results/*.csv`: bảng số liệu dạng văn bản, dòng đầu là tên cột.
- `results/*.mat`: cùng dữ liệu dạng nhị phân, gồm `header`, `data` và struct `T` truy cập theo tên cột.
- `results/all_results.mat`: struct `R` gom toàn bộ bảng, ví dụ `R.exp5_summary.req_elec_sim`.
- `results/params.json`: tham số mô phỏng, định nghĩa SNR, bias, β và môi trường chạy. Giá trị `null` nghĩa là Inf.
- `figures_matlab/*.png`: hình xuất bằng `make_figures.m`.

## 8. Môi trường đã chạy

- Mô phỏng Monte Carlo trong `results/*.csv`: GNU Octave 8.4 trên Linux 64-bit, seed 2026.
- Kiểm tra `quick_test.m` và vẽ toàn bộ hình: MATLAB Online R2026b, phiên bản 26.2.0.3386108.

## 9. Cấu trúc thư mục

```
dco_aco_vlc/
├── run_all_experiments.m   chạy toàn bộ, tham số 'full', 'figures', 'quick'
├── quick_test.m            kiểm tra nhanh
├── exp1_ber_vs_snr.m … exp5_summary.m
├── make_figures.m          vẽ 17 hình của báo cáo
├── init_sim.m              đường dẫn, seed
├── lib/                    các hàm mô phỏng, giải tích, xuất kết quả, vẽ hình
├── results/                CSV, MAT, JSON
└── figures_matlab/         PNG
```
