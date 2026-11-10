function lg = fig_legend(h, labels, ncol)
% FIG_LEGEND  Chu giai nhieu cot ben duoi truc (MATLAB R2018a tro len).
% GNU Octave va MATLAB cu khong co NumColumns -> dat chu giai ben phai truc.
if nargin < 3, ncol = 2; end
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    oldML = true;
else
    v = sscanf(version, '%d.%d');           % '9.4.0...' (R2018a), '24.2.0...' (R2024b)
    oldML = v(1) < 9 || (v(1) == 9 && v(2) < 4);
end
if oldML
    lg = legend(h, labels, 'Location', 'eastoutside');
else
    lg = legend(h, labels, 'Location', 'southoutside', 'NumColumns', ncol);
end
set(lg, 'FontSize', 9);
end
