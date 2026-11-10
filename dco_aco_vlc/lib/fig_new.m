function f = fig_new(w, h)
% FIG_NEW  Tao figure an (khong hien cua so) kich thuoc w x h inch de xuat PNG.
f = figure('Visible', 'off', 'Color', 'w');
set(f, 'PaperUnits', 'inches', 'PaperPosition', [0 0 w h], 'PaperSize', [w h]);
set(f, 'Units', 'inches', 'Position', [1 1 w h]);
end
