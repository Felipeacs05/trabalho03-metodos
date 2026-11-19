function [coef, y_ajust, residuos, R2] = mmq_periodico(t, y, P)
% MMQ_PERIODICO Ajusta modelo periodico linearizado via Minimos Quadrados.
% Modelo: y(t) = a0 + a1*cos(w*t) + b1*sin(w*t), onde w = 2*pi/P.

if nargin < 3
    error('mmq_periodico requer 3 argumentos: (t, y, P).');
end
if ~isscalar(P) || ~isnumeric(P) || P <= 0
    error('O periodo P deve ser um escalar positivo.');
end

t = double(t(:));
y = double(y(:));

if length(t) ~= length(y)
    error('Os vetores t e y devem ter o mesmo comprimento.');
end

coef = zeros(3, 1); y_ajust = zeros(size(y)); residuos = zeros(size(y)); R2 = 0;
end
