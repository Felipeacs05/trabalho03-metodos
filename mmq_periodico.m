function [coef, y_ajust, residuos, R2] = mmq_periodico(t, y, P)
% MMQ_PERIODICO Ajusta modelo periodico linearizado via Minimos Quadrados.
% Modelo: y(t) = a0 + a1*cos(w*t) + b1*sin(w*t), onde w = 2*pi/P.

coef = zeros(3, 1);
y_ajust = zeros(size(y));
residuos = zeros(size(y));
R2 = 0;
end
