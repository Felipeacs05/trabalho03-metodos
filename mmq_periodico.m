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

% Filtra observacoes validas (evita propagacao de NaN nas somatorias do MMQ)
valid = ~isnan(t) & ~isnan(y);
n_val = sum(valid);

if n_val < 3
    error('Sao necessarios pelo menos 3 pontos validos para ajustar o modelo periodico.');
end

t_val = t(valid);
y_val = y(valid);

w = 2 * pi / P;
c_val = cos(w * t_val);
s_val = sin(w * t_val);

% Montagem do sistema linear normal 3x3 (A * coef = B)
A = [ n_val,       sum(c_val),      sum(s_val);
      sum(c_val),  sum(c_val.^2),   sum(c_val .* s_val);
      sum(s_val),  sum(c_val .* s_val), sum(s_val.^2) ];

B = [ sum(y_val);
      sum(y_val .* c_val);
      sum(y_val .* s_val) ];

coef = zeros(3, 1); y_ajust = zeros(size(y)); residuos = zeros(size(y)); R2 = 0;
end
